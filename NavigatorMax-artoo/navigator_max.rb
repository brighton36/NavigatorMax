#!/usr/bin/env ruby
# encoding: UTF-8

#$: << "/home/cderose/Documents/development/artoo/lib"

NAVIGATOR_CONFIG = [File.dirname(__FILE__),'config.yaml'].join('/')

$: << File.dirname(__FILE__)
$: << [File.dirname(__FILE__), 'lib'].join('/')

require 'artoo'
require 'artoo-phidgets'
require 'core_overides'
require 'lib/navigator_definition'

class NavigatorMaxRobot < Artoo::Robot
  API_COMMANDS = %w(attributes state overide_controls save_mission missions 
    destroy_mission).collect(&:to_sym)

  # This will apply the api/devices per the config file:
  NavigatorDefinition.new(NAVIGATOR_CONFIG).register self

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
