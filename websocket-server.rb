#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'matrix'
require 'phidgets-ffi'

# Seems like this fixes our ffi crash issues. Huh.
GC.disable

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

# TODO: Maybe create a Matrix3x3 class?
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end

  def normalize
    ret = m3x3
    0.upto(2) do |i|
      length = Math.sqrt(self[i, 0] * self[i, 0] + self[i, 1] * self[i, 1] + self[i, 2] * self[i, 2])
      if length == 0.0
        ret[i, 0] = 0
        ret[i, 1] = 0
        ret[i, 2] = 0
      else
        ret[i, 0] = self[i, 0] / length
        ret[i, 1] = self[i, 1] / length
        ret[i, 2] = self[i, 2] / length
      end
    end

    ret
  end
end

# TODO: Clean this up, and maybe create a V3 class?
class Vector
  def x; self.send :[], 0; end
  def y; self.send :[], 1; end
  def z; self.send :[], 2; end
  def x=(v); self.send :[]=, 0, v; end
  def y=(v); self.send :[]=, 1, v; end
  def z=(v); self.send :[]=, 2, v; end

  def v3_crossproduct(vB)
    cross = v3(0,0,0)
    cross.x = y * vB.z - z * vB.y
    cross.y = z * vB.x - x * vB.z
    cross.z = x * vB.y - y * vB.x
    cross
  end

  def v3_dotproduct(vB)
    x * vB.x + y * vB.y + z * vB.z
  end
end

def v3(x, y, z)
  Vector[x,y,z]
end

def m3x3
 Matrix.build(3,3){0}
end

class OrientationSensor
  # This is kind of silly, but, since we can only pass a 32 bit number to an
  # on_spatial_data, it'll suffice. Basically, this is a counter to all the 
  # initialized sensors. Each sensor is guaranteed a unique entry in this table
  # which is used by the update proc
  @@instances = []

  def self.instance(id)
    @@instances[id]
  end

  ON_ATTACH = Proc.new do |device, instance_id|
    begin

    puts "Device attributes: #{device.attributes} attached"
    puts "Device: #{device.inspect}"

    orientation = OrientationSensor.instance instance_id
    orientation.on_attach device

    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  ON_ERROR = Proc.new do |device, obj, code, description|
    puts "Error #{code}: #{description}"
  end

  ON_DETACH = Proc.new do |device, instance_id|
    begin
      orientation = OrientationSensor.instance instance_id
      orientation.on_detach device
    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  ON_SPATIAL_DATA = Proc.new do |device, acceleration, magnetic_field, angular_rate, instance_id|
    begin
      #puts " Accel: #{acceleration.inspect} Mag: #{magnetic_field.inspect} Ang: #{angular_rate.inspect}"

      orientation = OrientationSensor.instance instance_id
      orientation.on_data device, acceleration, magnetic_field, angular_rate

      sleep 0.005 # Seems like omiting this might crash ruby. Might be an OSX thing...  (Might need tuning...)
    rescue Phidgets::Error::UnknownVal
    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  attr_accessor :acceleration_min, :acceleration_max, :gyroscope_min, 
    :gyroscope_max, :compass_min, :compass_max, 
    :acceleration, :compass, :gyroscope

  def initialize(serial_number)
    @@instances << self
    instances_id = @@instances.index self

    @is_connected = false
    @phidget = Phidgets::Spatial.new :serial_number => @serial_number
    @phidget.on_attach instances_id, &ON_ATTACH
    @phidget.on_error  instances_id, &ON_ERROR
    @phidget.on_detach instances_id, &ON_DETACH 
    @phidget.on_spatial_data instances_id, &ON_SPATIAL_DATA 
  end

  def on_attach(spatial)
    @is_connected = true

    @acceleration_max = spatial.accelerometer_axes[0].acceleration_max
    @acceleration_min = spatial.accelerometer_axes[0].acceleration_min
    @gyroscope_max = spatial.gyro_axes[0].angular_rate_max
    @gyroscope_min = spatial.gyro_axes[0].angular_rate_min
    @compass_max = spatial.compass_axes[0].magnetic_field_max
    @compass_min = spatial.compass_axes[0].magnetic_field_min
  end

  def on_detach(spatial)
    @is_connected = false
  end

  def device_attributes
    @phidget.attributes if @is_connected
  end

  def on_data(spatial, acceleration, magnetic_field, angular_rate)
    @acceleration = v3 *acceleration
    @gyroscope = v3 *angular_rate
    @compass = v3 *magnetic_field unless magnetic_field.any?{|n| n == 'Unknown'}
  end

  def acceleration_direction_cosine
    acos_accel = acceleration.normalize.collect{|n| Math.acos(n) }

    v3 acos_accel.x-Math::PI/2, 
      (acceleration.z < 0) ? (2 * Math::PI - acos_accel.y) : acos_accel.y, 0
  end
  
  def acceleration_direction_cosine_matrix 
    accel_dcv = acceleration_direction_cosine

    [
      # X-rotation: (Good)
      Matrix.rows([
        [1.0, 0, 0],
        [0, Math.cos(accel_dcv.y), Math.sin(accel_dcv.y) * (-1.0)],
        [0, Math.sin(accel_dcv.y), Math.cos(accel_dcv.y)]
      ]), 
      # Y-rotation:
      #Matrix.rows([
        #[Math.cos(accel_dcv.x), 0, Math.sin(accel_dcv.x)],
        #[0, 1.0, 0],
        #[Math.sin(accel_dcv.x) * (-1.0), 0, Math.cos(accel_dcv.x)]
      #]) #, 
      # Z-rotation:
      Matrix.rows([ 
        [Math.cos(accel_dcv.x), Math.sin(accel_dcv.x) * (-1.0), 0],
        [Math.sin(accel_dcv.x), Math.cos(accel_dcv.x), 0],
        [0, 0, 1.0]
      ]) 
    ].reduce(:*)
  end

  def acceleration_to_euler
    accel_dcv = acceleration_direction_cosine
    [accel_dcv.y, 0, accel_dcv.x]
  end

  # TODO: this should likely be nixed
  def last_data
    { :acceleration => @acceleration.to_a,  :gyroscope => @gyroscope.to_a, :compass => @compass.to_a }
  end

  def connected?; @is_connected; end
  
end


puts "Library Version: #{Phidgets::FFI.library_version}"
Phidgets::Log.enable :verbose

# This might belong in attach
orientation = OrientationSensor.new 302012
# TODO: orientation.zero_gyro!

# We'll use this to block the execution. Phidget seems to run as an 'interrupt' 
# to this proc:
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get spatial_attributes'
        ret[:spatial_attributes] = orientation.device_attributes
      when 'get spatial_extents'
        ret[:spatial_extents] = {
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_min => orientation.acceleration_min,
          :gyroscope_max => orientation.gyroscope_max,
          :gyroscope_min => orientation.gyroscope_min,
          :compass_max => orientation.compass_max,
          :compass_min => orientation.compass_min
        }
      when 'get spatial_data'
        ret[:spatial_data] = {
          :raw => { 
            :acceleration => orientation.acceleration.to_a,  
            :gyroscope => orientation.gyroscope.to_a, 
            :compass => orientation.compass.to_a },
          :euler_angles => {
            :acceleration => orientation.acceleration_to_euler.to_a },
          :direction_cosine_matrix => {
            :acceleration => orientation.acceleration_direction_cosine_matrix.to_a }
        }
    end if orientation.connected?

    ws.send ret.to_json
  end
end
