module Artoo::Drivers
  class PhidgetsInterfaceKit < PhidgetsDriver

    COMMANDS = [:sensor, :sensor_previous].freeze

    def initialize(params={})
      super params

      initialize_phidget(:InterfaceKit, params) do |ifkit_params, ifkit|
        @interval = ifkit_params[:interval] || 1.0
        
        @sensor_values = {} 
        @sensor_values_previous = {}

        @sensors = ifkit_params[:sensors] || []
        @sensors.each_with_index do |sensor, i|
          # TODO: Support a raw type
          
          # TODO: Raise an argument error if we're missing important keys
          case sensor[:type]
            when :temperature
              @phidget.ratiometric i, true
            when :humidity
              @phidget.ratiometric i, true
            when :voltage
              @phidget.ratiometric i, false
          end

          # We'll be using this a lot, might as well compute/store it here:
          sensor[:label] = [ sensor[:location].downcase.tr('^a-z0-9', '_'),
            sensor[:type].to_s].join('_').gsub(/_+/, '_').to_sym
        end
      end
    end

    # Sensors are referenced via "#{location.downcase}_#{type}" specifiers
    def sensor(sensor_label)
      @sensor_values[sensor_label.to_sym] if @sensor_values.has_key?(sensor_label.to_sym)
    end

    # Sensors are referenced via "#{location.downcase}_#{type}" specifiers
    def sensor_previous(sensor_label)
      @sensor_previous[sensor_label.to_sym] if @sensor_previous.has_key?(sensor_label.to_sym)
    end

    def start_driver
      every(@interval) do
        @sensor_previous = @sensor_values.dup

        @sensors.each_with_index do |sensor, i|
          sensor_label = sensor[:label]
          value = @phidget.sensors[i] # TODO: route this through the transformation below
          @sensor_values[sensor_label] = value

          update sensor_label, value unless @sensor_previous[sensor_label] == value
        end
      end

      super
    end

    private

    # Publishes events according to the button feedback
    def update(sensor_label, new_val)
      publish event_topic_name("sensor"), sensor_label.to_s, new_val
    end

    def as_temperature(val)
      # These magic numbers come from the phidget documentation
      val.to_f * 0.22222 - 61.111 if val > 0
    end

    # Returns the relative humidity (0-100%)
    def as_humidity(val)
      # These magic numbers come from the phidget documentation
      val.to_f * 0.1906 - 40.2 if val > 0
    end

    # Returns the voltage
    def as_voltage(val)
      # These magic numbers come from the phidget documentation
      (val.to_f / 200 - 2.5) / 0.0681 if val > 0
    end

  end
end
