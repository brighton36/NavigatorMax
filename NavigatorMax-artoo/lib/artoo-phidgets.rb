require 'artoo/drivers/driver'
require '../../phidgets_native/lib/phidgets_native'

module Artoo
  class PhidgetMissingSerial < StandardError; end

  module Drivers
    
    class StateDriver < Driver
      def initialize(*args)
        @updates_this_interval = 0
        @updates_per_second = 0
        @last_update_interval_at = Time.now.to_f
      end

      def sampled!(now)
        # Has it been more than a second since we last counted?
        if now > @last_update_interval_at + 1.0
          @last_update_interval_at = now
          @updates_per_second = @updates_this_interval
          @updates_this_interval = 1
        else
          @updates_this_interval += 1
        end

        @last_data_at = now
      end

      private

      def hashify_attributes(attrs)
        Hash.new.tap{ |h| attrs.each{|a| h[a] = self.send(a)} }
      end
    end

    class PhidgetsDriver < Driver
      def updates_per_second
        @phidget.sample_rate if @phidget
      end

      def connected?
        @phidget.is_attached? if @phidget
      end

      def device_attributes
        {:type=> @phidget.type, :name=> @phidget.name, 
          :serial_number => @phidget.serial_number, :version => @phidget.version, 
          :label => @phidget.label, :device_class => @phidget.device_class, 
          :device_id => @phidget.device_id} if @phidget
      end

      private

      def initialize_phidget(phidget_type, params, &block)
        servo_params = params[:additional_params]
        raise PhidgetMissingSerial unless servo_params.has_key? :serial
        
        phidget_klass = ::PhidgetsNative.const_get phidget_type
        @phidget = phidget_klass.new servo_params[:serial]
        @phidget.wait_for_attachment 10000
        block.call(servo_params, @phidget) if block
      end

      # TODO: Dry this out?
      def hashify_attributes(attrs)
        Hash.new.tap{ |h| attrs.each{|a| h[a] = self.send(a)} }
      end

    end
  end
end
