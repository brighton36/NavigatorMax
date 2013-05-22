#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'phidgets-ffi'

puts "Library Version: #{Phidgets::FFI.library_version}"

Phidgets::Log.enable :verbose
spatial = Phidgets::Spatial.new
#spatial.data_rate = 1000
spatial.on_attach  do |device, obj|
  puts "Device attributes: #{device.attributes} attached"
end

spatial.on_error do |device, obj, code, description|
	puts "Error #{code}: #{description}"
end

sleep 2

EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
  ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get spatial_attributes'
        ret[:spatial_attributes] = spatial.attributes.to_hash
      when 'get spatial_extents'
        ret[:spatial_extents] = { 
          :acceleration_max => spatial.accelerometer_axes[0].acceleration_max, 
          :acceleration_min => spatial.accelerometer_axes[0].acceleration_min,
          :gyroscope_max => spatial.gyro_axes[0].angular_rate_max,
          :gyroscope_min => spatial.gyro_axes[0].angular_rate_min,
          :compass_max => spatial.compass_axes[0].magnetic_field_max,
          :compass_min => spatial.compass_axes[0].magnetic_field_min
        }
      when 'get spatial_data'
          puts spatial.accelerometer_axes.inspect
        begin
           ret[:spatial_data] = {
            :acceleration => spatial.accelerometer_axes.collect(&:acceleration), 
            :gyroscope => spatial.gyro_axes.collect(&:angular_rate),
            :compass => spatial.compass_axes.collect(&:magnetic_field) }
         rescue Phidgets::Error::UnknownVal
           retry
         end
    end
    ws.send ret.to_json
  end
end
