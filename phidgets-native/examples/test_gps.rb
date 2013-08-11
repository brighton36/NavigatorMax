#!/usr/bin/env ruby
# encoding: UTF-8

$:.push *['%s/../lib/', '%s/lib/'].collect{|p| p % File.dirname(__FILE__) }
require 'console_table'
require 'phidgets_native'

Phidgets.enable_logging! :verbose

puts "Using Library version: "+Phidgets::LIBRARY_VERSION

gps = Phidgets::GPS.new(284771)
gps.wait_for_attachment 10000

trap("SIGINT") do
  puts "Sigint!"
  gps.close
  exit
end

# Print the basic attributes:
ConsoleTable.new(%w(Attribute Value)).output do
  [ ["Type", gps.type.inspect],
    ["Name", gps.name.inspect],
    ["Label", gps.label.inspect],
    ["Serial", gps.serial_number.inspect],
    ["Version", gps.version.inspect],
    ["Device class", gps.device_class.inspect],
    ["Device id", gps.device_id.inspect] ]
end

# And this updates every 5 seconds:
gps_attribs = ['Sample Rate', 'Is Fixed', '%-18s' % 'Latitude', '%-18s' % 'Longitude', 'Altitude', 
  'Heading', 'Velocity']
i = 0
begin
  ConsoleTable.new(gps_attribs).output(:header => (i == 0), :separator => false) do |columns|
    i+=1
    [ columns.collect{|attr| gps.send(attr.strip.tr(' ','_').downcase.to_sym).inspect } ]
  end while sleep(3)
rescue Phidgets::UnknownValError
  retry
end

gps.close
