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
