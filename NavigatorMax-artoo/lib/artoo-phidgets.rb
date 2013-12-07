require 'artoo/drivers/driver'
require '../../phidgets_native/lib/phidgets_native'

module Artoo
  class PhidgetMissingSerial < StandardError; end

  module Drivers
    class PhidgetsDriver < Driver
      private
      def initialize_phidget(phidget_type, params, &block)
        servo_params = params[:additional_params]
        raise PhidgetMissingSerial unless servo_params.has_key? :serial
        
        phidget_klass = ::PhidgetsNative.const_get phidget_type
        @phidget = phidget_klass.new servo_params[:serial]
        @phidget.wait_for_attachment 10000
        block.call(servo_params, @phidget)
      end
    end
  end
end
