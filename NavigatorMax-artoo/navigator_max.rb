#!/usr/bin/env ruby
# encoding: UTF-8

#$: << "/Users/cderose/Documents/development/artoo/lib"

$: << File.dirname(__FILE__)
$: << [File.dirname(__FILE__), 'lib'].join('/')

require 'artoo'
require 'artoo-phidgets'

class NavigatorMaxRobot < Artoo::Robot
  api :host => "0.0.0.0", :port => '8023'

=begin 
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
=end

  device :system, :driver => :system, 
    :primary_interface => (/linux/.match RUBY_PLATFORM) ? 'eth0' : 'en0'

  work do
    puts "Hello from the API running at #{api_host}:#{api_port}..."

  end

  def hello
    puts "HI"
  end
end

robots = []
robots << NavigatorMaxRobot.new(:name => "NavigatorMax", :commands => [:hello])
NavigatorMaxRobot.work!(robots)

