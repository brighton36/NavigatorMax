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

  def v3_length
    Math.sqrt(x * x + y * y + z * z)
  end

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
  ON_ATTACH = Proc.new do |device, obj|
    puts "Device attributes: #{device.attributes} attached"
  end

  ON_ERROR = Proc.new do |device, obj, code, description|
    puts "Error #{code}: #{description}"
  end

  ON_DETACH = Proc.new do |device, obj|
    puts "#{device.attributes.inspect} detached"
  end

  ON_SPATIAL_DATA = Proc.new do |device, acceleration, magnetic_field, angular_rate, obj|
    begin

      #ev_spatial_extents ||= {
        #:acceleration_max => spatial.accelerometer_axes[0].acceleration_max, 
        #:acceleration_max => spatial.accelerometer_axes[0].acceleration_max, 
        #:acceleration_min => spatial.accelerometer_axes[0].acceleration_min,
        #:gyroscope_max => spatial.gyro_axes[0].angular_rate_max,
        #:gyroscope_min => spatial.gyro_axes[0].angular_rate_min,
        #:compass_max => spatial.compass_axes[0].magnetic_field_max,
        #:compass_min => spatial.compass_axes[0].magnetic_field_min
      #}

      #ev_spatial_attributes ||= spatial.attributes.to_hash.dup

      puts "Accel: #{acceleration.inspect} Mag: #{magnetic_field.inspect} Ang: #{angular_rate.inspect}" if i % 20 == 0

      #usable_spatial.phid_tick(spatial)

      #ev_spatial = {
        #:acceleration => acceleration, 
        #:gyroscope    => angular_rate,
        #:compass      => magnetic_field ,
        #:orientation  => usable_spatial.rotMatrix.to_a
      #}
      #sleep 0.005 # Seems like omiting this might crash ruby. Might be an OSX thing...  (Might need tuning...)
    rescue Phidgets::Error::UnknownVal
    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  def initialize(serial_number)
    @phidget = Phidgets::Spatial.new :serial_number => @serial_number
    @phidget.on_attach &ON_ATTACH
    @phidget.on_error  &ON_ERROR
    @phidget.on_detach &ON_DETACH 
    @phidget.on_spatial_data &ON_SPATIAL_DATA 
  end
end

ev_spatial = {}
ev_spatial_extents = {}
ev_spatial_attributes = {}

puts "Library Version: #{Phidgets::FFI.library_version}"
Phidgets::Log.enable :verbose

sleep 2

# This might belong in attach
orientation = OrientationSensor.new 302012 
# TODO: orientation.zeroGyro spatial

# We'll use this to block the execution. Phidget seems to run as an 'interrupt' 
# to this proc:
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get spatial_attributes'
        ret[:spatial_attributes] = ev_spatial_attributes
      when 'get spatial_extents'
        ret[:spatial_extents] = ev_spatial_extents
      when 'get spatial_data'
        ret[:spatial_data] = ev_spatial.dup
    end
    ws.send ret.to_json
  end
end
