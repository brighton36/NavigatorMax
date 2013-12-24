require 'vmstat'
require 'socket'
require 'rusage'

module Artoo::Drivers
  class System < Driver
    DEVICE_ATTRIBUTES = [:hostname, :uname, :boot_time, :cpu_arch, :serial_number, 
      :ruby_description, :primary_interface, :memory_total, :root_filesystem]
    POLLED_ATTRIBUTES = [:updates_per_second, :snapshot_at, :memory_free,
      :memory_swaprates, :root_filesystem_free, :load_avg, :uptime, :gc_rate,
      :cpu_percent_user, :cpu_percent_system, :cpu_percent_idle, :network_send_rate,
      :network_recv_rate, :process_resident_memory, :process_percent_user,
      :process_percent_system, :wifi_network, :wifi_signal, :wifi_noise ]

    COMMANDS = (DEVICE_ATTRIBUTES+POLLED_ATTRIBUTES+[:state]).freeze


    attr_accessor :updates_per_second
    attr_accessor *DEVICE_ATTRIBUTES

    attr_accessor :network_send_rate, :network_recv_rate, :cpu_percent_user, 
      :cpu_percent_system, :cpu_percent_idle, :gc_rate, :process_percent_user,
      :process_percent_system, :swap_in_rate, :swap_out_rate

    OSX_SYSTEM_PROFILER = '/usr/sbin/system_profiler'
    OSX_AIRPORT = '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

    def initialize(params={})
      super params
      # This is to track the sampling rates:
      @updates_this_interval = 0
      @updates_per_second = 0
      @last_update_interval_at = Time.now.to_f
      #/Sensor

      @primary_interface = params[:additional_params][:primary_interface].to_s
      @snapshot = Vmstat.snapshot
      @cpu_count = @snapshot.cpus.length

      @hostname = Socket.gethostname 
      @uname = `uname -a`
      @boot_time = @snapshot.boot_time

      @ruby_description = RUBY_DESCRIPTION

      on_poll 
      every(1){ on_poll }
    end

    def state
      puts "Called state!"
      hashify_attributes POLLED_ATTRIBUTES
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

    def device_attributes
      hashify_attributes DEVICE_ATTRIBUTES
    end

    def polled_attributes
      hashify_attributes POLLED_ATTRIBUTES
    end

    def on_poll
      last_snapshot = @snapshot
      @snapshot = Vmstat.snapshot

      last_rusage = @rusage
      @rusage = Process.rusage

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

        # System CPU Stats:
        system_ticks, user_ticks, idle_ticks = [:system, :user, :idle].collect{|ticker|
          [@snapshot, last_snapshot].collect{|snap| 
            snap.cpus.collect(&ticker).reduce(&:+).to_f }.reduce(&:-) / poll_delta }

        total_ticks = system_ticks + idle_ticks + user_ticks
        @cpu_percent_user = user_ticks / total_ticks * 100
        @cpu_percent_system = system_ticks / total_ticks * 100
        @cpu_percent_idle = idle_ticks / total_ticks * 100

        # Swap stats:
        @swap_in_rate, @swap_out_rate = [:pageins, :pageouts].collect{ |ticker| 
          [@snapshot, last_snapshot].collect{ |snap| 
            snap.memory.send(ticker)}.reduce(&:-).to_f * @snapshot.memory.pagesize / poll_delta }
      end

      # Process CPU Stats:
      if last_rusage
        @process_percent_user, @process_percent_system = %w(utime stime).collect{|a|
          (@rusage.send(a) - last_rusage.send(a)) / poll_delta * 100}
      end

      # GC Stats
      @gc_rate = ( @gc_count.to_f - last_gc_count.to_f ) / poll_delta if last_gc_count

      # This allows us to cache these commands for a second or so
      @airport = nil
    end

    def serial_number
      # Serial Number (system)
      @serial_number ||= if system_profiler?
        system_profiler('Serial Number \(system\)')
      else
        'TODO'
      end
    end

    def cpu_arch
      @cpu_arch ||= if system_profiler?
        '%s (%sx) %s %s' % ['Model Identifier', 'Total Number of Cores', 'Processor Name', 
          'Processor Speed'].collect{|for_value| system_profiler(for_value)}
      else
        'TODO: Linux version' 
      end
    end

    def memory_free
      @snapshot.memory.free * @snapshot.memory.pagesize
    end

    def memory_total
      %w(free wired active inactive).collect{|attr| @snapshot.memory.send(attr)}.reduce(:+) * @snapshot.memory.pagesize
    end

    def memory_swaprates
      'In: %.2f KiB Out: %.2f Kib' % [swap_in_rate / 1024 , swap_out_rate / 1024 ]
    end

    def root_filesystem
      fs = @snapshot.disks.find{|d| d.mount == '/'}
      '%s:%s: %.2f GiB' % [fs.origin, fs.type.to_s,
        fs.total_blocks.to_f * fs.block_size / 1024 / 1024 / 1024]
    end

    def root_filesystem_free
      fs = @snapshot.disks.find{|d| d.mount == '/'}
      '%.2f GiB' % [ fs.free_blocks.to_f * fs.block_size / 1024 / 1024 / 1024 ]
    end

    def load_avg
      load_avg = @snapshot.load_average
      %w(one_minute five_minutes fifteen_minutes).collect{|t| load_avg.send t}
    end

    def process_resident_memory
      @snapshot.task.resident_size
    end

    def process_virtual_memory
      @snapshot.task.virtual_size
    end

    def snapshot_at
      @snapshot.at
    end

    # Reports in seconds
    def uptime
      (@snapshot.at - @snapshot.boot_time).to_i
    end

    def wifi_network
      (airport?) ? 
        ('"%s" Ch. %s (%s)' % ['SSID','channel','link auth'].collect{|v| airport(v)}) : 
        'TODO'
    end

    def wifi_noise
      (airport?) ? airport('agrCtlNoise') : 'TODO'
    end

    def wifi_signal
      (airport?) ? airport('agrCtlRSSI') : 'TODO'
    end

    private

    def primary_netif(for_snapshot = nil)
      (for_snapshot || @snapshot).network_interfaces.find{|i| i.name == @primary_interface.to_sym}
    end

    def system_profiler?
      @has_system_profiler = File.exists? OSX_SYSTEM_PROFILER
    end

    def system_profiler(for_value)
      if system_profiler?
        @system_profiler ||= `#{OSX_SYSTEM_PROFILER} SPHardwareDataType`
        osx_command_parse @system_profiler, for_value
      end
    end

    def airport?
      @has_airport = File.exists? OSX_AIRPORT
    end

    def airport(for_value = nil)
      if airport?
        @airport ||= `#{OSX_AIRPORT} -I`
        osx_command_parse @airport, for_value
      end
    end

    def osx_command_parse(output, for_value)
      $1 if /^[ ]*#{for_value}:[ ]*(.+)/.match(output)
    end


    def hashify_attributes(attrs)
      Hash.new.tap{ |h| attrs.each{|a| h[a] = self.send(a)} }
    end
  end
end
