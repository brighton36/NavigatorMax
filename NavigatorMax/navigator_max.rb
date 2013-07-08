#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'matrix'
require 'phidgets-ffi'

$: << 'lib'
$: << 'sensors'
require 'phidgets_overides'
require 'core_overides'
require 'orientation_sensor'
require 'gps_sensor'

puts "Library Version: #{Phidgets::FFI.library_version}"
Phidgets::Log.enable :verbose


orientation = OrientationSensor.new 302012, 
  [0.441604, 0.045493, 0.176548, 0.002767, 1.994358, 2.075937, 2.723117, -0.019360, -0.008005, -0.020036, 0.007017, -0.010891, 0.009283]
gps = GpsSensor.new 284771

# TODO: orientation.zero_gyro!

trap("INT") do
  puts "Script terminated by user."
  orientation.close
  gps.close
  exit
end

# We'll use this to block the execution. Phidget seems to run as an 'interrupt' 
# to this proc:
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get application_metadata'
        ret[:gps_attributes] = gps.device_attributes
        ret[:spatial_attributes] = orientation.device_attributes
        ret[:spatial_extents] = {
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_min => orientation.acceleration_min,
          :gyroscope_max => orientation.gyroscope_max,
          :gyroscope_min => orientation.gyroscope_min,
          :compass_max => orientation.compass_max,
          :compass_min => orientation.compass_min
        }
      when 'get application_state'
        ret.merge!({ 
          :gps => {
            :updates_per_second => gps.updates_per_second,
            :is_fixed  => gps.is_fixed?,
            :latitude  => gps.latitude,
            :longitude => gps.longitude,
            :altitude  => gps.altitude,
            :heading   => gps.heading,
            :velocity  => gps.velocity,
            :time      => gps.time
          },
          :spatial_data => {
            :updates_per_second => orientation.updates_per_second,
            :raw => { 
              :acceleration => orientation.acceleration.to_a,  
              :gyroscope    => orientation.gyroscope.to_a, 
              :compass      => orientation.compass.to_a },
            :euler_angles => {
              :acceleration => orientation.acceleration_to_euler.to_a,
              :gyroscope    => orientation.gyroscope_to_euler.to_a,
              :compass      => orientation.compass_bearing_to_euler.to_a},
            :direction_cosine_matrix => {
              :acceleration => orientation.acceleration_dcm.to_a,
              :gyroscope    => orientation.gyroscope_dcm.to_a,
              :compass      => orientation.compass_bearing_dcm.to_a } }
        } )
    end if orientation.connected?

    ws.send ret.to_json
  end
end
