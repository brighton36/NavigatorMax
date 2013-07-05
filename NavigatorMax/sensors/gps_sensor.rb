#!/usr/bin/env ruby
# encoding: UTF-8

require 'phidget_sensor'
require 'time'

class GpsSensor < PhidgetSensor
  attr_accessor :latitude, :longitude, :altitude

  def initialize(serial_number)
    super Phidgets::GPS.new(:serial_number => @serial_number)

    @is_fixed = false
  end

  def on_attach(phidget)
    super
    @is_fixed = @phidget.position_fix_status
    @phidget.on_position_change self 
    @phidget.on_position_fix_status_change self 
  end

  def on_position_change(lat, long, alt)
    @latitude, @longitude, @altitude = lat, long, alt

    sampled! Time.now.to_f
  end

  def on_position_fix_status_change(fix_status)
    @is_fixed = fix_status
  end

  def is_fixed?
    @is_fixed
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
      ret = Time.parse( '%s-%s-%s %s:%s:%s UTC' % [
        date_parts[:year], date_parts[:month], date_parts[:day], 
        time_parts[:hours], time_parts[:minutes], time_parts[:seconds] ] )
      puts ret.inspect
      ret
    end
  end

  private

  def catch_unknown
    yield

	  rescue Phidgets::Error::UnknownVal => e
			puts "Exception caught: #{e.message}"
  end
end
