class Sensor
  attr_accessor :updates_per_second

  # This is kind of silly, but, since we can only pass a 32 bit number to an
  # on_spatial_data, it'll suffice. Basically, this is a counter to all the 
  # initialized sensors. Each sensor is guaranteed a unique entry in this table
  # which is used by the update proc. Possibly a better solution is to re-write
  # the event handlers to work the way they do with the on_data
  @@instances = []

  def self.instance(id)
    @@instances[id]
  end

  def initialize(*args)
    @@instances << self
    @instance_id = @@instances.index(self)

    # This is to track the sampling rates:
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

end

class PhidgetSensor < Sensor
 
  ON_ATTACH = Proc.new do |device, instance_id|
    begin
      puts "Device attributes: #{device.attributes} attached"
      puts "Device: #{device.inspect}"

      puts "Instance..."+@on_attach_obj.inspect
      PhidgetSensor.instance(instance_id).on_attach device

    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  ON_ERROR = Proc.new do |device, obj, code, description|
    puts "Error #{code}: #{description}"
  end

  ON_DETACH = Proc.new do |device, instance_id|
    begin
      PhidgetSensor.instance(instance_id).on_detach device
    rescue Exception => e
      puts "ERROR" + e.inspect
    end
  end

  def initialize(phidget)
    super

    @is_connected = false

    @phidget = phidget 
    @phidget.on_attach self
    @phidget.on_error  @instance_id, &ON_ERROR
    @phidget.on_detach @instance_id, &ON_DETACH 
  end

  def on_attach(device)
    @is_connected = true
    puts "Device attributes: #{device.attributes} attached"
    puts "Device: #{device.inspect}"
  end

  def on_detach(*args)
    @is_connected = false
  end


  def device_attributes
    @phidget.attributes if connected?
  end

  def connected?
    @is_connected
  end

  def close
    @is_connected = false
    @phidget.close
  end

end
