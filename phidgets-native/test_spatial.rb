#!/usr/bin/env ruby
# encoding: UTF-8

require './lib/phidgets_native.bundle'

class Phidget::Spatial
  def test_method
    'uhuhu'
  end
end

p = Phidget::Spatial.new(302012, 16,
  [ 0.441604, 0.045493, 0.176548, 0.002767, 1.994358, 2.075937, 2.723117, 
    -0.019360, -0.008005, -0.020036, 0.007017, -0.010891, 0.009283 ] )
p.wait_for_attachment 10000
puts p.inspect

trap("SIGINT") do
  puts "Sigint!"
  p.close
  exit
end

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

#sleep 5


puts "Test:"+p.test_method.inspect
while sleep(5) do
  puts "loop" 

  puts "(%d Hz) Gyro: %s, Compass: %s, Accel: %s" % [p.sample_rate, 
    p.gyro.inspect, p.compass.inspect, p.accelerometer.inspect]
end
p.close
