#!/usr/bin/env ruby
# encoding: UTF-8

require './lib/phidgets_native.bundle'

class Phidget::Spatial
  def test_method
    'uhuhu'
  end
end

Phidget.enable_logging! :verbose

Phidget.log :info, "Huzzzah!"

puts "Using Library version: "+Phidget::LIBRARY_VERSION

p = Phidget::Spatial.new(302012)
p.wait_for_attachment 10000
p.data_rate = 16
p.compass_correction = [ 0.441604, 0.045493, 0.176548, 0.002767, 1.994358, 
  2.075937, 2.723117, -0.019360, -0.008005, -0.020036, 0.007017, -0.010891, 0.009283 ]

puts "We set the correction to:"+p.compass_correction.inspect
puts "We set the data_rate to:"+p.data_rate.inspect
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
puts "Data Rate Min: "+p.data_rate_min.inspect
puts "Data Rate Max: "+p.data_rate_max.inspect

puts "accelerometer_axes: "+p.accelerometer_axes.inspect
puts "compass_axes: "+p.compass_axes.inspect
puts "gyro_axes: "+p.gyro_axes.inspect

puts "accelerometer_min: "+p.accelerometer_min.inspect
puts "accelerometer_max: "+p.accelerometer_max.inspect
puts "compass_min: "+p.compass_min.inspect
puts "compass_max: "+p.compass_max.inspect
puts "gyro_min: "+p.gyro_min.inspect
puts "gyro_max: "+p.gyro_max.inspect

p.reset_compass_correction!
#sleep 5


puts "Test:"+p.test_method.inspect
poll_i = 0
while sleep(5) do
  poll_i += 1

  if poll_i == 2
    puts "Zero'ing the gyro, let's see what happens"
    p.zero_gyro! 
  end

  puts "loop" 

  puts "(%d Hz) Gyro: %s, Compass: %s, Accel: %s" % [p.sample_rate, 
    p.gyro.inspect, p.compass.inspect, p.accelerometer.inspect]

end
p.close
