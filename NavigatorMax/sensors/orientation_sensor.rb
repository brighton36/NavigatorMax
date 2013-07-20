#!/usr/bin/env ruby
# encoding: UTF-8

require 'phidget_sensor'

class OrientationSensor < PhidgetSensor
  attr_accessor :acceleration_min, :acceleration_max, :gyroscope_min, 
    :gyroscope_max, :compass_min, :compass_max, 
    :acceleration, :compass, :gyroscope

  def initialize(serial_number, compass_correction_params)
    super Phidgets::Spatial.new(:serial_number => @serial_number)

    @compass_correction_params = compass_correction_params
    @phidget.on_spatial_data self 
  end

  def on_attach(spatial)
    super spatial

    spatial.set_compass_correction_parameters *@compass_correction_params
    @acceleration_max = spatial.accelerometer_axes[0].acceleration_max
    @acceleration_min = spatial.accelerometer_axes[0].acceleration_min
    @gyroscope_max = spatial.gyro_axes[0].angular_rate_max
    @gyroscope_min = spatial.gyro_axes[0].angular_rate_min
    @compass_max = spatial.compass_axes[0].magnetic_field_max
    @compass_min = spatial.compass_axes[0].magnetic_field_min
  end

  def on_data(acceleration, magnetic_field, angular_rate)
    @acceleration = v3 *acceleration
    @compass = v3 *magnetic_field unless magnetic_field.any?{|n| n == 'Unknown'}

    now = Time.now.to_f
    if @last_data_at.nil?
      @gyroscope = v3(0,0,0)
    else
      timestamp_delta = now - @last_data_at

      0.upto(2) do |i|
        @gyroscope[i] = (@gyroscope[i] + timestamp_delta * angular_rate[i]) % 360
      end
    end

    sampled! now

    # TODO : We should probably calculate our dcm's here.
  end

  # TODO: This should be based on gravity, not acceleration
  # NOTE: 
  #  * This bearing is in radians, not angles. 1 radian is where the usb cable
  #    plugs in, 0 radians is the front of the device
  #  * This registers the magnetic north, and not true north
  def compass_bearing_mag
    roll, pitch = acceleration_direction_cosine.to_a # TODO: We're calculating this too much, cache somehow?

    # Yaw Angle - about axis 2
    #   tan(yaw) = (mz * sin(roll) – my * cos(roll)) / 
    #              (mx * cos(pitch) + my * sin(pitch) * sin(roll) + mz * sin(pitch) * cos(roll))
    #   Use Atan2 to get our range in (-180 - 180)
    #
    #   Yaw angle == 0 degrees when axis 0 is pointing at magnetic north
	  yaw = Math.atan2(
		   (@compass.z * Math.sin(roll)) - 
       (@compass.y * Math.cos(roll)),
		   (@compass.x * Math.cos(pitch)) + 
       (@compass.y * Math.sin(pitch) * Math.sin(roll)) + 
       (@compass.z * Math.sin(pitch) * Math.cos(roll)) )

    (@acceleration.z < 0) ? ( yaw - Math::PI / 2 ) : ( yaw - Math::PI * 1.5 )
  end

  def compass_bearing_dcm
    direction_cosine_matrix *compass_bearing_to_euler
  end

  def compass_bearing_to_euler
    [0, 0, compass_bearing_mag ]
  end

  def gyroscope_to_euler
    [@gyroscope.x, @gyroscope.y, @gyroscope.z ].collect{|n| n / 360 * 2 * Math::PI}
  end

  def gyroscope_dcm
    direction_cosine_matrix( (gyroscope_to_euler[0]-Math::PI * 0.5) * -1.0, 
      gyroscope_to_euler[1], gyroscope_to_euler[2] * -1.0, 'YZX' )
  end

  # TODO: Are we doing this right? Should we be handling the dcm calcs in here?
  def acceleration_direction_cosine
    # Roll Angle - about axis 0
    #   tan(roll) = gy/gz
    #   Use Atan2 so we have an output os (-180 - 180) degrees
	  roll = Math.atan2 @acceleration.y, @acceleration.z
 
    # Pitch Angle - about axis 1
    #   tan(pitch) = -gx / (gy * sin(roll angle) * gz * cos(roll angle))
    #   Pitch angle range is (-90 - 90) degrees
	  pitch = Math.atan -@acceleration.x / ((@acceleration.y * Math.sin(roll)) + (@acceleration.z * Math.cos(roll)))
 
    v3 roll, pitch, 0
  end
  
  def acceleration_dcm 
    accel_dcv = acceleration_direction_cosine

    direction_cosine_matrix accel_dcv.x * -1.00 + Math::PI / 2, 0, accel_dcv.y
  end

  # TODO: We broke this - fix
  def acceleration_to_euler
    accel_dcv = acceleration_direction_cosine
    [accel_dcv.y, 0, accel_dcv.x]
  end

  private

  def direction_cosine_matrix(around_x, around_y, around_z, in_order = 'XYZ')
    rotations = {
      # X-rotation:
      :x => Matrix.rows([
        [1.0, 0, 0],
        [0, Math.cos(around_x), Math.sin(around_x) * (-1.0)],
        [0, Math.sin(around_x), Math.cos(around_x)]
      ]), 

      # Y-rotation:
      :y => Matrix.rows([
        [Math.cos(around_y), 0, Math.sin(around_y)],
        [0, 1.0, 0],
        [Math.sin(around_y) * (-1.0), 0, Math.cos(around_y)]
      ]), 

      # Z-rotation:
      :z => Matrix.rows([ 
        [Math.cos(around_z), Math.sin(around_z) * (-1.0), 0],
        [Math.sin(around_z), Math.cos(around_z), 0],
        [0, 0, 1.0]
      ]) 
    }

    in_order.chars.collect{ |axis| rotations[axis.downcase.to_sym] }.reduce(:*)
  end 
end