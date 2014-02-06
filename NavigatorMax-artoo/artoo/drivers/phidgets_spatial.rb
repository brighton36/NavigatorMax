module Artoo::Drivers
  class PhidgetsSpatial < PhidgetsDriver

    POLLED_ATTRIBUTES = [] # TODO
    DEVICE_ATTRIBUTES = [] # TODO

    attr_accessor :acceleration_min, :acceleration_max, :gyroscope_min, 
      :gyroscope_max, :compass_min, :compass_max, 
      :acceleration, :compass, :gyroscope

    COMMANDS = ([:device_attributes, :polled_attributes]+DEVICE_ATTRIBUTES+POLLED_ATTRIBUTES).freeze

    def initialize(params={})
      super params

      initialize_phidget(:Spatial, params) do |spatial_params, spatial|
        spatial.zero_gyro!
        spatial.data_rate = 8
        spatial.compass_correction = spatial_params[:compass_correction] if spatial_params.has_key? :compass_correction

        @acceleration_max = spatial.accelerometer_max[0]
        @acceleration_min = spatial.accelerometer_min[0]
        @gyroscope_max = spatial.gyro_max[0]
        @gyroscope_min = spatial.gyro_min[0]
        @compass_max = spatial.compass_max[0]
        @compass_min = spatial.compass_min[0]
      end
    end

    def device_attributes
      super.merge( {
        :accelerometer_axes => @phidget.accelerometer_axes, 
        :compass_axes => @phidget.compass_axes, :gyro_axes => @phidget.gyro_axes,
        :acceleration_max => acceleration_max, :acceleration_min => acceleration_min,
        :gyroscope_max => gyroscope_max, :gyroscope_min => gyroscope_min,
        :compass_max => compass_max, :compass_min => compass_min } )
    end

    def polled_attributes
      { :updates_per_second => updates_per_second,
        :raw => { 
          :acceleration => arrayify(acceleration),  
          :gyroscope    => arrayify(gyroscope), 
          :compass      => arrayify(compass) },
        :euler_angles => {
          :acceleration => arrayify(acceleration_to_euler),
          :gyroscope    => arrayify(gyroscope_to_euler),
          :compass      => arrayify(compass_bearing_to_euler),
          :orientation  => arrayify(orientation_to_euler) },
        :direction_cosine_matrix => {
          :acceleration => arrayify(acceleration_to_dcm),
          :gyroscope    => arrayify(gyroscope_to_dcm),
          :compass      => arrayify(compass_bearing_to_dcm),
          :orientation  => arrayify(orientation_to_dcm) },
        :quaternion => {
          :orientation => arrayify(orientation_to_quaternion)
        }
      }
    end

    def acceleration; @phidget.accelerometer; end
    def acceleration_to_euler; @phidget.accelerometer_to_euler; end
    def acceleration_to_dcm; @phidget.accelerometer_to_dcm; end

    def compass; @phidget.compass; end
    def compass_bearing; @phidget.compass_bearing; end
    def compass_bearing_to_euler; @phidget.compass_bearing_to_euler; end
    def compass_bearing_to_dcm; @phidget.compass_bearing_to_dcm; end

    def gyroscope; @phidget.gyro; end
    def gyroscope_to_dcm; @phidget.gyro_to_dcm; end

    def orientation_to_quaternion; @phidget.orientation_to_quaternion; end
    def orientation_to_dcm; @phidget.orientation_to_dcm; end
    def orientation_to_euler; @phidget.orientation_to_euler; end

    # TODO: cify:
    def gyroscope_to_euler
      gyro = v3(*gyroscope)
      [gyro.x, gyro.y, gyro.z ].collect{|n| n / 360 * 2 * Math::PI}
    end

    # /cify

    private

    # If we're not null, and respond to to_a, return an array:
    def arrayify(a)
      ( a && a.respond_to?(:to_a) ) ? a.to_a : nil
    end
  end
end
