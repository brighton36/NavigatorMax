#!/usr/bin/env ruby
# encoding: UTF-8

class GpsSensor < Sensor
  POLLED_ATTRIBUTES = [ :updates_per_second, :is_fixed, :latitude, :longitude, 
    :altitude, :heading, :velocity, :time]

  def initialize(serial_number)
    @phidget = PhidgetsNative::GPS.new(serial_number)
    @phidget.wait_for_attachment 10000
  end

  def device_attributes
    { :type=> @phidget.type, :name=> @phidget.name, 
      :serial_number => @phidget.serial_number, :version => @phidget.version, 
      :label => @phidget.label, :device_class => @phidget.device_class, 
      :device_id => @phidget.device_id
    } if connected?
  end

  def polled_attributes
    hashify_attributes POLLED_ATTRIBUTES
  end

  def close
    @phidget.close
  end

  def updates_per_second
    @phidget.sample_rate
  end

  def connected?
    @phidget.is_attached?
  end

  def is_fixed?
    @phidget.is_fixed?
  end

  alias is_fixed is_fixed?

  def latitude
    @phidget.latitude
  end

  def longitude
    @phidget.longitude
  end

  def altitude
    @phidget.altitude
  end

  def heading
    @phidget.heading
  end

  def velocity
    @phidget.velocity
  end

  def time
    @phidget.now_at_utc
  end

end
