module Artoo::Drivers
  class PhidgetsAdvancedServo < PhidgetsDriver
    
    COMMANDS = [:move, :min, :center, :max,
      :current_position, :max_position, :min_position, :center_position, 
      :position_range].freeze

    def initialize(params={})
      super params

      initialize_phidget(:AdvancedServo, params) do |servo_params, servo|
        @servo_num = servo_params[:servo_num] || 0
       
        # Let's set up some device defaults. Be advised that these aren't supported
        # on all (most?) servos: 
        servo.acceleration @servo_num, 
          servo_params[:acceleration] || servo.acceleration_max[@servo_num]
        servo.velocity_limit @servo_num, 
          servo_params[:velocity_max] || servo.velocity_max[@servo_num]
        servo.servo_type @servo_num, servo_params[:servo_type] || :default
        servo.speed_ramping @servo_num, servo_params[:speed_ramping] || false
        servo.engaged @servo_num, true
        servo.position_max @servo_num, servo_params[:max_position] || 180
        servo.position_min @servo_num, servo_params[:min_position] || 0
      end
    end

    # Moves to specified angle
    # @param [Integer] position must be between the min and max for the device
    def move(pos)
      @phidget.position @servo_num, pos
    end

    # Moves to min position
    def min
      move min_position
    end

    # Moves to center position
    def center
      move(min_position + position_range/2)
    end

    # Moves to max position
    def max
      move max_position
    end

    def center_position
      min_position + position_range / 2
    end

    def current_position
      @phidget.positions[@servo_num]
    end

    def min_position
      @phidget.position_min(@servo_num)
    end

    def max_position
      @phidget.position_max(@servo_num)
    end

    def position_range
      max_position - min_position
    end

  end
end
