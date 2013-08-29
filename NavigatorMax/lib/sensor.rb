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

  private

  def hashify_attributes(attrs)
    Hash.new.tap{ |h| attrs.each{|a| h[a] = self.send(a)} }
  end
end

