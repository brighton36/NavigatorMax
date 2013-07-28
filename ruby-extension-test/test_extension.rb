#!/usr/bin/env ruby
# encoding: UTF-8

require './lib/ruby_extension_test.bundle'
class Phidget::Spatial
  def test_method
    'uhuhu'
  end
end

p = Phidget::Spatial.new(302012)

puts p.inspect
sleep 5

puts "Type:"+p.type.inspect
puts "Name:"+p.name.inspect
puts "Label:"+p.label.inspect
puts "Serial:"+p.serial_number.inspect
puts "Version:"+p.version.inspect

puts "Device class: "+p.device_class.inspect
puts "Device id: "+p.device_id.inspect

puts "Sample Rate: "+p.sample_rate.inspect

puts "accelerometer_axes: "+p.accelerometer_axes.inspect
puts "compass_axes: "+p.compass_axes.inspect
puts "gyro_axes: "+p.gyro_axes.inspect

puts "accelerometer_min: "+p.accelerometer_min.inspect
puts "accelerometer_max: "+p.accelerometer_max.inspect
puts "compass_min: "+p.compass_min.inspect
puts "compass_max: "+p.compass_max.inspect
puts "gyro_min: "+p.gyro_min.inspect
puts "gyro_max: "+p.gyro_max.inspect

puts "Test:"+p.test_method.inspect
p.close
