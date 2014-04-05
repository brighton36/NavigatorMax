# encoding: UTF-8

module Artoo::Drivers
  class PhidgetsInterfaceKit < PhidgetsDriver

    DEVICE_ATTRIBUTES = []
    POLLED_ATTRIBUTES = [ :temperatures, :humidities, :voltages, :updates_per_second ]

    COMMANDS = ([:device_attributes, :polled_attributes]+DEVICE_ATTRIBUTES+POLLED_ATTRIBUTES+[:sensor, :sensor_previous]).freeze

    def initialize(params={})
      super params

      initialize_phidget(:InterfaceKit, params) do |ifkit_params, ifkit|
        @interval = ifkit_params[:interval] || 0.2
        
        @sensor_values = {} 
        @sensor_values_previous = {}

        @sensors = ifkit_params[:sensors] || []
        @sensors.each_with_index do |sensor, i|
          next unless sensor

          raise ArgumentError, "All sensors must specify a :type" unless sensor.has_key? :type
          raise ArgumentError, "All sensors must specify a :location" unless sensor.has_key? :location

          case sensor[:type].to_sym
            when :temperature
              @phidget.ratiometric i, true
              sensor[:transform] ||= lambda {|val|
                # These magic numbers come from the phidget documentation
                val.to_f * 0.22222 - 61.111 if val > 0
              }
            when :humidity
              @phidget.ratiometric i, true
              sensor[:transform] ||= lambda {|val|
                # These magic numbers come from the phidget documentation
                val.to_f * 0.1906 - 40.2 if val > 0
              }
            when :voltage
              @phidget.ratiometric i, false
              sensor[:transform] ||= lambda {|val|
                # These magic numbers come from the phidget documentation
                (val.to_f / 200 - 2.5) / 0.0681 if val > 0
              }
            when :raw
              raise ArgumentError, "Raw Sensors must specify :ratiometric" unless sensor.has_key? :ratiometric
              @phidget.ratiometric i, sensor[:ratiometric] 
          end

          # Generate a label, if none was provided:
          sensor[:label] ||= [ sensor[:location].downcase.tr('^a-z0-9', '_'),
            sensor[:type].to_s].join('_').gsub(/_+/, '_').to_sym
        end
      end
    end

    def device_attributes
      super.merge({
        :temperatures => labels_for(:temperature), 
        :humidities => labels_for(:humidity), 
        :voltages => labels_for(:voltage)
      })
    end

    def polled_attributes
      hashify_attributes POLLED_ATTRIBUTES
    end

    def updates_per_second
      @phidget.sensor_sample_rates
    end

    # Returns the temperature is celsius
    def temperatures
      # These magic numbers come from the phidget documentation
      collect_type(:temperature){ |i| sensor(i).to_f * 0.22222 - 61.111 if sensor(i) > 0}
    end

    # Returns the relative humidity (0-100%)
    def humidities
      # These magic numbers come from the phidget documentation
      collect_type(:humidity){ |i| sensor(i).to_f * 0.1906 - 40.2 if sensor(i) > 0} 
    end

    def voltages
      collect_type(:voltage){ |i| (sensor(i).to_f / 200 - 2.5) / 0.0681 if sensor(i) > 0} 
    end

    # Just a shortcut:
    def sensor(offset)
      @phidget.sensors[offset] 
    end

    private

    def collect_type(type, &block)
      Hash[*@sensors.to_enum(:each_with_index).collect{|d,i| 
        [d[:location], block.call(i, d)] if d && d[:type].to_sym == type 
      }.compact.flatten]
    end

    def labels_for(type)
      @sensors.collect{|d| d[:location] if d && d[:type].to_sym == type}.compact
    end

  end
end
