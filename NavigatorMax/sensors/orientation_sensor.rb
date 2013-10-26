#!/usr/bin/env ruby
# encoding: UTF-8

class OrientationSensor < PhidgetSensor
  attr_accessor :acceleration_min, :acceleration_max, :gyroscope_min, 
    :gyroscope_max, :compass_min, :compass_max, 
    :acceleration, :compass, :gyroscope

  def initialize(serial_number, options)
    super(PhidgetsNative::Spatial, serial_number)
    @phidget.zero_gyro!
    @phidget.data_rate = 8
    @phidget.compass_correction = options[:compass_correction] if options.has_key? :compass_correction

    @acceleration_max = @phidget.accelerometer_max[0]
    @acceleration_min = @phidget.accelerometer_min[0]
    @gyroscope_max = @phidget.gyro_max[0]
    @gyroscope_min = @phidget.gyro_min[0]
    @compass_max = @phidget.compass_max[0]
    @compass_min = @phidget.compass_min[0]
  end

  def device_attributes
    super.merge( {
      :accelerometer_axes => @phidget.accelerometer_axes, 
      :compass_axes => @phidget.compass_axes, :gyro_axes => @phidget.gyro_axes,
      :acceleration_max => acceleration_max, :acceleration_min => acceleration_min,
      :gyroscope_max => gyroscope_max, :gyroscope_min => gyroscope_min,
      :compass_max => compass_max, :compass_min => compass_min } )
  end

  def polled_attributes
    { :updates_per_second => updates_per_second,
      :raw => { 
        :acceleration => arrayify(acceleration),  
        :gyroscope    => arrayify(gyroscope), 
        :compass      => arrayify(compass) },
      :euler_angles => {
        :acceleration => arrayify(acceleration_to_euler),
        :gyroscope    => arrayify(gyroscope_to_euler),
        :compass      => arrayify(compass_bearing_to_euler)},
      :direction_cosine_matrix => {
        :acceleration => arrayify(acceleration_dcm),
        :gyroscope    => arrayify(gyroscope_dcm),
        :compass      => arrayify(compass_bearing_dcm) } }
  end

  def acceleration; v3ify(@phidget.accelerometer); end
  def compass; v3ify(@phidget.compass); end
  def gyroscope; v3ify(@phidget.gyro); end

  def acceleration_to_euler; @phidget.acceleration_to_euler; end

  # TODO: cify:
  
  # TODO: This should be based on gravity, not acceleration
  # NOTE: 
  #  * This bearing is in radians, not angles. 1 radian is where the usb cable
  #    plugs in, 0 radians is the front of the device
  #  * This registers the magnetic north, and not true north
  def compass_bearing
    roll, pitch = acceleration_to_roll_and_pitch # TODO: Grab this from gravity_roll_and_pitch

    comp = self.compass
    return nil unless compass

    # Yaw Angle - about axis 2
    #   tan(yaw) = (mz * sin(roll) – my * cos(roll)) / 
    #              (mx * cos(pitch) + my * sin(pitch) * sin(roll) + mz * sin(pitch) * cos(roll))
    #   Use Atan2 to get our range in (-180 - 180)
    #
    #   Yaw angle == 0 degrees when axis 0 is pointing at magnetic north
	  yaw = Math.atan2(
		   (comp.z * Math.sin(roll)) - 
       (comp.y * Math.cos(roll)),
		   (comp.x * Math.cos(pitch)) + 
       (comp.y * Math.sin(pitch) * Math.sin(roll)) + 
       (comp.z * Math.sin(pitch) * Math.cos(roll)) )

    (acceleration.z < 0) ? ( yaw - Math::PI / 2 ) : ( yaw - Math::PI * 1.5 )
  end

  def compass_bearing_to_euler
    cbm = compass_bearing
    (cbm) ? [0, 0, cbm ] : nil
  end

  def gyroscope_to_euler
    [gyroscope.x, gyroscope.y, gyroscope.z ].collect{|n| n / 360 * 2 * Math::PI}
  end
  # /cify

  def acceleration_dcm; dcmify acceleration_to_euler; end
  def compass_bearing_dcm; dcmify compass_bearing_to_euler; end
  def gyroscope_dcm
    direction_cosine_matrix( (gyroscope_to_euler[0]-Math::PI * 0.5) * -1.0, 
      gyroscope_to_euler[1], gyroscope_to_euler[2] * -1.0, 'YZX' )
  end

  private

  # TODO: Nix
  def acceleration_to_roll_and_pitch
    @phidget.instance_eval{ acceleration_to_roll_and_pitch }
  end

  def direction_cosine_matrix(around_x, around_y, around_z, in_order = 'XYZ')
    @phidget.instance_eval{ 
      direction_cosine_matrix around_x, around_y, around_z, in_order  }
  end 
  # TODO: /Nix

  # If we're not null, and respond to to_a, return an array:
  def arrayify(a)
    ( a && a.respond_to?(:to_a) ) ? a.to_a : nil
  end

  # If we're not null, and respond to to_a, return a v3
  def v3ify(a)
    ( a && a.respond_to?(:to_a) ) ? v3(*a) : nil
  end

  # If we're not null, and respond to to_a, return a direction_cosine_matrix
  def dcmify(a)
    ( a && a.respond_to?(:to_a) ) ? direction_cosine_matrix(*a) : nil
  end
end
