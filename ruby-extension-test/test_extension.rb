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
sleep 2
# {:type=>"PhidgetSpatial", 
# :name=>"Phidget Spatial 3/3/3", 
# :label=>"", 
# :serial_number=>302012, 
# :version=>401, 
# :accelerometer_axes=>3, 
# :compass_axes=>3, 
# :gyro_axes=>3
#
# :device_class=>:spatial, 
# :device_id=>:spatial_accel_gyro_compass, 
puts "Type:"+p.type.inspect
puts "Name:"+p.name.inspect
puts "Label:"+p.label.inspect
puts "Serial:"+p.serial_number.inspect
puts "Version:"+p.version.inspect

puts "Device class: "+p.device_class.inspect
puts "Device id: "+p.device_id.inspect

puts "accelerometer_axes: "+p.accelerometer_axes.inspect
puts "compass_axes: "+p.compass_axes.inspect
puts "gyro_axes: "+p.gyro_axes.inspect

puts "Test:"+p.test_method.inspect
p.close
