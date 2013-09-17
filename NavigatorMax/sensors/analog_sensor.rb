#!/usr/bin/env ruby
# encoding: UTF-8

class AnalogSensor < PhidgetSensor
  POLLED_ATTRIBUTES = [ :temperatures, :humidities, :voltages, :updates_per_second ]

  def initialize(serial_number, options ={})
    super(PhidgetsNative::InterfaceKit, serial_number)
    @definitions = options[:sensors]

    @definitions.each_with_index do |definition, i|
      case definition[:type]
        when :temperature
          @phidget.ratiometric i, true
        when :humidity
          @phidget.ratiometric i, true
        when :voltage
          @phidget.ratiometric i, false
      end
    end
  end

  def device_attributes
    super.merge({
      :temperatures => labels_for(:temperature), 
      :humidities => labels_for(:humidity), 
      :voltages => labels_for(:voltage)
    })
  end

  def polled_attributes
    hashify_attributes POLLED_ATTRIBUTES
  end

  def updates_per_second
    @phidget.sensor_sample_rates
  end

  # Returns the temperature is celsius
  def temperatures
    # These magic numbers come from the phidget documentation
    collect_type(:temperature){ |i| sensor(i).to_f * 0.22222 - 61.111 if sensor(i) > 0}
  end

  # Returns the relative humidity (0-100%)
  def humidities
    # These magic numbers come from the phidget documentation
    collect_type(:humidity){ |i| sensor(i).to_f * 0.1906 - 40.2 if sensor(i) > 0} 
  end

  def voltages
    collect_type(:voltage){ |i| (sensor(i).to_f / 200 - 2.5) / 0.0681 if sensor(i) > 0} 
  end

  # Just a shortcut:
  def sensor(offset)
    @phidget.sensors[offset] 
  end

  private

  def collect_type(type, &block)
    Hash[*@definitions.to_enum(:each_with_index).collect{|d,i| 
      [d[:location], block.call(i, d)] if d[:type] == type 
    }.compact.flatten]
  end

  def labels_for(type)
    @definitions.collect{|d| d[:location] if d[:type] == type}.compact
  end
end
