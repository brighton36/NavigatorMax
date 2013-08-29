#!/usr/bin/env ruby
# encoding: UTF-8

class AnalogSensor

  def initialize(serial_number, options ={})
    @phidget = PhidgetsNative::InterfaceKit.new(serial_number)
    @phidget.wait_for_attachment 10000

    # TODO: Handle the options[:types]
  end

  def device_attributes
    { :type=> @phidget.type, :name=> @phidget.name, 
      :serial_number => @phidget.serial_number, :version => @phidget.version, 
      :label => @phidget.label, :device_class => @phidget.device_class, 
      :device_id => @phidget.device_id
    } if connected?
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
end
