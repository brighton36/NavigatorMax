module Artoo::Drivers
  class PhidgetsInterfaceKit < PhidgetsDriver

    COMMANDS = [:comm_rate, :sensor, :sensor_previous].freeze

    def initialize(params={})
      super params

      initialize_phidget(:InterfaceKit, params) do |ifkit_params, ifkit|
        @interval = ifkit_params[:interval] || 0.2
        
        @sensor_values = {} 
        @sensor_values_previous = {}

        @sensors = ifkit_params[:sensors] || []
        @sensors.each_with_index do |sensor, i|
          
          raise ArgumentError, "All sensors must specify a :type" unless sensor.has_key? :type
          raise ArgumentError, "All sensors must specify a :location" unless sensor.has_key? :location

          case sensor[:type]
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

    def comm_rate
      @phidget.sample_rate
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
          value = @phidget.sensors[i]
          value = sensor[:transform].call value if sensor.has_key? :transform
          @sensor_values[sensor_label] = value
          update sensor_label, value unless @sensor_previous[sensor_label] == value
        end
      end

      super
    end

    private

    # Publishes events according to the button feedback
    def update(sensor_label, new_val)
      publish event_topic_name("update"), {:label => sensor_label.to_s, :value => new_val}
    end

  end
end
