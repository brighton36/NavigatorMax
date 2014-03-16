#!/usr/bin/env ruby
# encoding: UTF-8

#$: << "/home/cderose/Documents/development/artoo/lib"

$: << File.dirname(__FILE__)
$: << [File.dirname(__FILE__), 'lib'].join('/')

require 'artoo'
require 'artoo-phidgets'
require 'core_overides'

class NavigatorMaxRobot < Artoo::Robot
  API_COMMANDS = %w(attributes state overide_controls save_mission missions 
    destroy_mission).collect(&:to_sym)

  api :host => "0.0.0.0", :port => '8023'

  device :system, :driver => :system, 
    :primary_interface => (/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'
=begin
  # Note that we could make the max a bit higher, but not the min. And, I want 
  # them equidistant, to make the calculations easier:
  device :rudder, :driver => :phidgets_advanced_servo, :serial => 305160, 
    :servo_num => 0, :max_position => 165, :min_position => 60 

  # NOTE: The max_throttle is actually about 140+ on my model, but, I wanted to
  # cap the speed. Also, the absolute min_velocity is 92, 91 is 'zero' throttle 
  # and 80 is to give us a bit less sensitivity at the low end.
  device :throttle, :driver => :phidgets_advanced_servo, :serial => 306238, 
    :servo_num => 0, :max_position => 112, :min_position => 80

  device :analogs, :driver => :phidgets_interface_kit, :serial => 337305,
    :interval => 0.5,
    :sensors => [ {:type => :humidity, :location => "Cabin"},
      {:type => :temperature, :location => "Engine"}, 
      {:type => :temperature, :location => "Cabin"}, 
      nil, 
      nil, 
      {:type => :voltage, :location => 'InterfaceKit'},
      {:type => :voltage, :location => "MinnowBoard"},
      {:type => :voltage, :location => "Batteries"} ]

  device :gps, :driver => :phidgets_gps, :serial => 284771 
  device :orientation, :driver => :phidgets_spatial, :serial => 302012, 
    :compass_correction => [ 0.338590, 0.227589, 0.173635, -0.077661, 2.608094, 
      2.742003, 3.510178, -0.043266, -0.049816, -0.044693, 0.045490, -0.064236, 
      0.057208 ]
=end

  work do
    puts "Hello from NavigatorMax running at #{api_host}:#{api_port}..."

    throttle.min if respond_to? :throttle
  end

  def initialize(attribs = {})
    super({:commands => API_COMMANDS}.merge(attribs))
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
    rudder.move rudder.min_position + (heading.to_f + 1.0)/2.0 * rudder.position_range if rudder

    throttle.move throttle.min_position + acceleration.to_f * throttle.position_range if throttle
  end

  def save_mission(attribs)
    @missions ||= {}
    @missions[ attribs[:id] ] = attribs
    true
  end

  def missions
    @missions || {}
  end

  def destroy_mission(id)
    @missions.delete id
    true
  end
end

NavigatorMaxRobot.work! [ NavigatorMaxRobot.new(:name => "NavigatorMax") ]
