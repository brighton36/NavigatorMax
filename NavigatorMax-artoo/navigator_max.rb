#!/usr/bin/env ruby
# encoding: UTF-8

#$: << "/home/cderose/Documents/development/artoo/lib"

$: << File.dirname(__FILE__)
$: << [File.dirname(__FILE__), 'lib'].join('/')

require 'artoo'
require 'artoo-phidgets'
require 'core_overides'

class NavigatorMaxRobot < Artoo::Robot
  api :host => "0.0.0.0", :port => '8023'

  device :system, :driver => :system, 
    :primary_interface => (/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'
=begin
  # Note that we could make the max a bit higher, but not the min. And, I want 
  # them equidistant, to make the calculations easier:
  device :rudder, :driver => :phidgets_advanced_servo, :serial => 305160, 
    :servo_num => 0, :max_position => 165, :min_position => 60 

  device :throttle, :driver => :phidgets_advanced_servo, :serial => 306238, 
    :servo_num => 0, :max_position => 100, :min_position => 0

  device :analogs, :driver => :phidgets_interface_kit, :serial => 337305,
    :interval => 0.5,
    :sensors => [ {:type => :humidity, :location => "Cabin"},
      {:type => :temperature, :location => "Cabin"}, 
      {:type => :temperature, :location => "ESC"}, 
      {:type => :temperature, :location => "Engine"}, 
      {:type => :voltage, :location => 'Battery'},
      {:type => :voltage, :location => "ESC"},
      {:type => :voltage, :location => "Engine"},
      {:type => :voltage, :location => "Computer"} ]

  device :gps, :driver => :phidgets_gps, :serial => 284771 
  device :orientation, :driver => :phidgets_spatial, :serial => 302012, 
    :compass_correction => [ 0.338590, 0.227589, 0.173635, -0.077661, 2.608094, 
      2.742003, 3.510178, -0.043266, -0.049816, -0.044693, 0.045490, -0.064236, 
      0.057208 ]
=end

  work do
    puts "Hello from the API running at #{api_host}:#{api_port}..."

    throttle.min if throttle
  end

  def attributes
    Hash[*devices.collect{|key, device| [key, device.device_attributes]}.flatten]
  end

  def state
    Hash[*devices.collect{|key, device| [key, device.polled_attributes]}.flatten]
  end

  # Heading is between -1 and 1
  # Acceleration is between 0 and 1
  def overide_controls(heading, acceleration)
    rudder.move (heading.to_f + 1.0)/2.0 * rudder.position_range if rudder

    throttle.move acceleration.to_f * throttle.position_range if throttle
  end
end

attribs = {:name => "NavigatorMax", :commands => [:attributes, :state, :overide_controls]}
NavigatorMaxRobot.work! [ NavigatorMaxRobot.new(attribs) ]
