#!/usr/bin/env ruby
# encoding: UTF-8

#$: << "/Users/cderose/Documents/development/artoo/lib"

$: << File.dirname(__FILE__)
$: << [File.dirname(__FILE__), 'lib'].join('/')

require 'artoo'
require 'artoo-phidgets'
require 'core_overides'

class NavigatorMaxRobot < Artoo::Robot
  api :host => "0.0.0.0", :port => '8023'

  # Note that we could make the max a bit higher, but not the min. And, I want 
  # them equidistant, to make the calculations easier:
  device :rudder, :driver => :phidgets_advanced_servo, :serial => 305367, 
    :servo_num => 0, :max_position => 165, :min_position => 60 

  device :throttle, :driver => :phidgets_advanced_servo, :serial => 305534, 
    :servo_num => 0 # TODO: figure out the min/max

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

  device :system, :driver => :system, 
    :primary_interface => (/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'

  device :orientation, :driver => :phidgets_spatial, :serial => 302012, 
    :compass_correction => [0.441604, 0.045493, 0.176548, 0.002767, 1.994358, 
      2.075937, 2.723117, -0.019360, -0.008005, -0.020036, 0.007017, -0.010891, 
      0.009283]

  device :gps, :driver => :phidgets_gps, :serial => 284771 

  work do
    puts "Hello from the API running at #{api_host}:#{api_port}..."

  end

  def attributes
    Hash[*devices.collect{|key, device| [key, device.device_attributes]}.flatten]
  end

  def state
    Hash[*devices.collect{|key, device| [key, device.polled_attributes]}.flatten]
  end
end

robots = []
robots << NavigatorMaxRobot.new(:name => "NavigatorMax", :commands => [:attributes, :state])
NavigatorMaxRobot.work!(robots)

