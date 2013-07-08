#!/usr/bin/env ruby
# encoding: UTF-8

# NOTE:
#   Mostly the reason we did all this was because the event handlers were 
#   segfaulting when garbage collection was on. I'm not 100% sure that I know
#   what's going on, but switching to FFI::Function and not passing user
#   pointers seemed to fix the problem

module Phidgets::Common
  def on_attach(obj)
	  @on_attach_obj = obj
    @on_attach = FFI::Function.new(:int, [:pointer, :pointer]) do |handle, obj_ptr|
      load_device_attributes
      @on_attach_obj.on_attach self
    end

    Phidgets::FFI::Common.set_OnAttach_Handler(@handle, @on_attach, nil)

	  true
 end
end

class Phidgets::Spatial
  
  # NOTE: 
  #   * I changed the event handler from a Proc to an FFI::Function\
  #   * I wrapped the code in an exception handler
  #   * Rather than pass an obj pointer, I set the @on_spatial_data_obj
  def on_spatial_data(obj)
    @on_spatial_data_obj = obj

    @on_spatial_data = FFI::Function.new(:void, 
      [:pointer, :pointer, :uint8]) do |device, obj_ptr, data, data_count|
      begin
        # Dist-Code
        acceleration = []
        if accelerometer_axes.size > 0
          acceleration = [accelerometer_axes[0].acceleration, accelerometer_axes[1].acceleration, accelerometer_axes[2].acceleration]
        end

        magnetic_field= []
        if compass_axes.size > 0 
          #Even when there is a compass chip, sometimes there won't be valid data in the event.
          begin
            magnetic_field = [compass_axes[0].magnetic_field, compass_axes[1].magnetic_field, compass_axes[2].magnetic_field]
          rescue Phidgets::Error::UnknownVal => e
            magnetic_field = ['Unknown', 'Unknown', 'Unknown']
          end
        end

        angular_rate = []
        if gyro_axes.size > 0
          angular_rate = [gyro_axes[0].angular_rate, gyro_axes[1].angular_rate, gyro_axes[2].angular_rate]
        end
        # /Dist-Code
        @on_spatial_data_obj.on_data acceleration.dup, magnetic_field.dup, angular_rate.dup
      rescue Phidgets::Error::UnknownVal
      rescue Exception => e
        puts "ERROR" + e.inspect
      end
    end

    Klass.set_OnSpatialData_Handler(@handle, @on_spatial_data, nil)
  end
end

class Phidgets::GPS
  
  # NOTE: 
  #   * I changed the event handler from a Proc to an FFI::Function
  #   * I wrapped the code in an exception handler
  #   * Rather than pass an obj pointer, I set the @on_position_change/@on_position_fix_status_change
  def on_position_change(obj)
	  @on_position_change_obj = obj
    @on_position_change = FFI::Function.new(:int, 
      [:pointer, :pointer, :double, :double, :double]) { |device, obj_ptr, lat, long, alt|
      @on_position_change_obj.on_position_change lat, long, alt
    }
    Klass.set_OnPositionChange_Handler(@handle, @on_position_change, nil)
  end
end
