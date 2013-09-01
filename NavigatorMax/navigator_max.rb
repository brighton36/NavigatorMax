#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require 'em-websocket'
require 'json'
require 'matrix'
require 'phidgets_native'

REQUIRE_LIBS = %w(lib sensors).collect{|p| [File.dirname(__FILE__),p,'*.rb'].join('/')}
Dir[*REQUIRE_LIBS].each{ |lib_path| require lib_path }

puts "Library Version: #{PhidgetsNative::LIBRARY_VERSION}"
PhidgetsNative.enable_logging! :verbose

sensors = {
  system: SystemSensor.new((/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'), 
  orientation: OrientationSensor.new(302012, :compass_correction => [0.441604, 
    0.045493, 0.176548, 0.002767, 1.994358, 2.075937, 2.723117, -0.019360, 
    -0.008005, -0.020036, 0.007017, -0.010891, 0.009283]), 
  gps: GpsSensor.new(284771), 
  analog: AnalogSensor.new(337305, :sensors => [
    {:type => :humidity, :location => "Cabin"},
    {:type => :temperature, :location => "Cabin"}, 
    {:type => :temperature, :location => "ESC"}, 
    {:type => :temperature, :location => "Engine"}, 
    {:type => :voltage, :location => 'Battery'},
    {:type => :voltage, :location => "ESC"},
    {:type => :voltage, :location => "Engine"},
    {:type => :voltage, :location => "Computer"}
  ])
}

# For now - this blocks execution. We'll likely want to init a ruby thread above
# this to manage the vessel.
EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => false) do |ws|
  Signal.trap("INT")  { puts "Handling INT"; sensors.values.each{|s| s.close}; EventMachine.stop }
  Signal.trap("TERM") { puts "Handling TERM"; sensors.values.each{|s| s.close}; EventMachine.stop }
  
  #ws.onerror   { |e| puts "Error: #{e.message}" }

  ws.onmessage do |req| 
    response = {:ts => Time.new.strftime('%H:%M:%S.%L'), :request => req }

    case req.downcase
      when 'get application_metadata'
        response.merge!( Hash[*sensors.collect{|key, sensor| 
          [key, sensor.device_attributes]}.flatten] )
      when 'get application_state'
        response.merge!( Hash[*sensors.collect{|key, sensor| 
          [key, (sensor.connected?) ? sensor.polled_attributes : nil]}.flatten] )
    end

    ws.send response.to_json
  end
end
