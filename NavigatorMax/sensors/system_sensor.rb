require "sys/cpu"
require 'vmstat'
require 'socket'

class SystemSensor < Sensor
  include Sys

  DEVICE_ATTRIBUTES = [:hostname, :uname, :boot_time, :cpu_arch, :ruby_description, 
    :primary_interface]

  attr_accessor *DEVICE_ATTRIBUTES

  attr_accessor :network_send_rate, :network_recv_rate, :cpu_percent_user, 
    :cpu_percent_system, :cpu_percent_idle, :gc_rate

  OSX_SYSTEM_PROFILER = '/usr/sbin/system_profiler'

  def initialize(primary_interface)
    super

    @primary_interface = primary_interface.to_s
    @snapshot = Vmstat.snapshot
    @cpu_count = @snapshot.cpus.length

    @hostname = Socket.gethostname
    @uname = `uname -a`
    @boot_time = @snapshot.boot_time

    @cpu_arch = '%sx %s (%s/%s) at %s' % [@cpu_count, CPU.model, 
      CPU.architecture, CPU.machine, cpu_frequency]
    @ruby_description = RUBY_DESCRIPTION

    @poller = Thread.new(self){|sensor| sensor.on_poll while sleep(1) }
  end

  def close
    Thread.kill @poller if @poller
    @poller = nil
  end

  def device_attributes
    Hash[*DEVICE_ATTRIBUTES.collect{|a| [a,self.send(a)]}.flatten]
  end

  def on_poll
    last_snapshot = @snapshot
    @snapshot = Vmstat.snapshot

    last_gc_count = @gc_count
    @gc_count = GC.count

    sampled! @snapshot.at.to_f

    if last_snapshot
      # Since the interval time isn't necessarily (or even likely to be) a second
      # we correct with a linear adjustment with this:
      poll_delta = @snapshot.at - last_snapshot.at

      # Network stats:
      this_intf = primary_netif
      last_intf = primary_netif(last_snapshot)

      @network_send_rate = (
        (this_intf.out_bytes - last_intf.out_bytes).to_f / poll_delta).to_i
      @network_recv_rate = (
        (this_intf.in_bytes - last_intf.in_bytes).to_f / poll_delta).to_i

      # CPU Stats:
      system_ticks, user_ticks, idle_ticks = [:system, :user, :idle].collect{|ticker|
        [@snapshot, last_snapshot].collect{|snap| 
          snap.cpus.collect(&ticker).reduce(&:+).to_f }.reduce(&:-) / poll_delta }

      total_ticks = system_ticks + idle_ticks + user_ticks
      @cpu_percent_user = user_ticks / total_ticks * 100
      @cpu_percent_system = system_ticks / total_ticks * 100
      @cpu_percent_idle = idle_ticks / total_ticks * 100
    end

    # GC Stats
    @gc_rate = ( @gc_count.to_f - last_gc_count.to_f ) / poll_delta if last_gc_count

  end

  def cpu_frequency
    if CPU.respond_to?(:cpu_freq)
      CPU.cpu_freq
    elsif system_profiler
      $1 if /^[ ]*Processor Speed:[ ]*(.+)/.match system_profiler
    else
      'Unknown' 
    end
  end

  def memory
    mem = @snapshot.memory

    'Free: %.1f MiB, Total: %.1f MiB' % [ mem.free, 
      (mem.free + mem.wired + mem.active + mem.inactive) 
    ].collect{|m| m * mem.pagesize / 1024 / 1024}
  end

  def filesystem
    fs = @snapshot.disks.find{|d| d.mount == '/'}
    '%s:%s, Free: %.1f GiB, Total: %.1f GiB' % ([fs.origin, fs.type.to_s]+
     [fs.free_blocks, fs.total_blocks].collect{|size| size.to_f * fs.block_size / 1024 / 1024 / 1024} )
  end

  def load_avg
    load_avg = @snapshot.load_average
    %w(one_minute five_minutes fifteen_minutes).collect{|t| load_avg.send t}
  end

  def snapshot_at
    @snapshot.at
  end

  # Reports in seconds
  def uptime
    (@snapshot.at - @snapshot.boot_time).to_i
  end

  def network_signal
    # /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I
  end

  private

  def primary_netif(for_snapshot = nil)
    (for_snapshot || @snapshot).network_interfaces.find{|i| i.name == @primary_interface.to_sym}
  end

  def system_profiler
    @system_profiler ||= `#{OSX_SYSTEM_PROFILER} SPHardwareDataType` if File.exists? OSX_SYSTEM_PROFILER
  end

end
