#!/usr/bin/env ruby
# encoding: UTF-8

require 'phidget_sensor'
require 'time'

class GpsSensor < PhidgetSensor
  attr_accessor :latitude, :longitude, :altitude

  def initialize(serial_number)
    super Phidgets::GPS.new(:serial_number => @serial_number)
  end

  def on_attach(phidget)
    super phidget
    @phidget.on_position_change self 
  end

  def on_position_change(lat, long, alt)
    @latitude, @longitude, @altitude = lat, long, alt

    sampled! Time.now.to_f
  end

  def is_fixed?
    @phidget.position_fix_status
  end

  def heading
    catch_unknown{ @phidget.heading }
  end

  def velocity
    catch_unknown{ @phidget.velocity }
  end

  def time
    catch_unknown do 
      # Note: I didn't think there was much need-for or ability to use microseconds
      # though they are available from the phidget
      time_parts = @phidget.time
      date_parts = @phidget.date
      Time.parse( '%s-%s-%s %s:%s:%s UTC' % [
        date_parts[:year], date_parts[:month], date_parts[:day], 
        time_parts[:hours], time_parts[:minutes], time_parts[:seconds] ] )
    end
  end

  private

  def catch_unknown
    yield

	  rescue Phidgets::Error::UnknownVal => e
			puts "Exception caught: #{e.message}"
  end
end
