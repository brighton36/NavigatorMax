#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'matrix'
require 'phidgets_native'

$: << 'lib'
$: << 'sensors'
require 'sensor'
require 'core_overides'
require 'orientation_sensor'
require 'gps_sensor'
require 'system_sensor'

puts "Library Version: #{PhidgetsNative::LIBRARY_VERSION}"
PhidgetsNative.enable_logging! :verbose

system = SystemSensor.new (/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'
orientation = OrientationSensor.new 302012, 
  [0.441604, 0.045493, 0.176548, 0.002767, 1.994358, 2.075937, 2.723117, -0.019360, -0.008005, -0.020036, 0.007017, -0.010891, 0.009283]
gps = GpsSensor.new 284771


# We'll use this to block the execution. Phidget seems to run as an 'interrupt' 
# to this proc:
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  Signal.trap("INT")  { puts "Handling INT"; gps.close; orientation.close; EventMachine.stop }
  Signal.trap("TERM") { puts "Handling TERM"; gps.close; orientation.close; EventMachine.stop }
  
  #ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    ret = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get application_metadata'
        ret[:system_attributes] = system.device_attributes
        ret[:gps_attributes] = gps.device_attributes
        ret[:spatial_attributes] = orientation.device_attributes.merge({:extents => {
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_max => orientation.acceleration_max, 
          :acceleration_min => orientation.acceleration_min,
          :gyroscope_max => orientation.gyroscope_max,
          :gyroscope_min => orientation.gyroscope_min,
          :compass_max => orientation.compass_max,
          :compass_min => orientation.compass_min } } )
      when 'get application_state'
        ret.merge!({ 
          :system => {
            :updates_per_second => system.updates_per_second,
            :snapshot_at => system.snapshot_at,
            :memory_free => system.memory_free,
            :memory_swaprates => system.memory_swaprates,
            :root_filesystem_free  => system.root_filesystem_free,
            :load_avg    => system.load_avg,
            :uptime      => system.uptime,
            :gc_rate     => system.gc_rate,
            :cpu_percent_user   => system.cpu_percent_user,
            :cpu_percent_system => system.cpu_percent_system,
            :cpu_percent_idle   => system.cpu_percent_idle,
            :network_send_rate  => system.network_send_rate,
            :network_recv_rate  => system.network_recv_rate,
            :process_resident_memory => system.process_resident_memory,
            :process_percent_user    => system.process_percent_user,
            :process_percent_system  => system.process_percent_system,
            :wifi_network => system.wifi_network,
            :wifi_signal  => system.wifi_signal,
            :wifi_noise   => system.wifi_noise
          },
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
