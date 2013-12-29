module Artoo::Drivers
  class PhidgetsGps < PhidgetsDriver
    DEVICE_ATTRIBUTES = []
    POLLED_ATTRIBUTES = [ :updates_per_second, :is_fixed, :latitude, :longitude, 
      :altitude, :heading, :velocity, :time]

    COMMANDS = ([:device_attributes, :polled_attributes]+DEVICE_ATTRIBUTES+POLLED_ATTRIBUTES).freeze

    def initialize(params={})
      super params

      initialize_phidget(:GPS, params) 
    end

    def polled_attributes
      hashify_attributes POLLED_ATTRIBUTES
    end

    def is_fixed?
      @phidget.is_fixed?
    end

    alias is_fixed is_fixed?

    def latitude
      @phidget.latitude
    end

    def longitude
      @phidget.longitude
    end

    def altitude
      @phidget.altitude
    end

    def heading
      @phidget.heading
    end

    def velocity
      @phidget.velocity
    end

    def time
      @phidget.now_at_utc
    end

  end
end
