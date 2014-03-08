require 'vmstat'
require 'socket'
require 'rusage'

module Artoo::Drivers
  class System < StateDriver
    DEVICE_ATTRIBUTES = [:hostname, :uname, :boot_time, :cpu_arch, :serial_number, 
      :ruby_description, :primary_interface, :memory_total, :root_filesystem]
    POLLED_ATTRIBUTES = [:updates_per_second, :snapshot_at, :memory_free,
      :memory_swaprates, :root_filesystem_free, :load_avg, :uptime, :gc_rate,
      :cpu_percent_user, :cpu_percent_system, :cpu_percent_idle, :network_send_rate,
      :network_recv_rate, :process_resident_memory, :process_percent_user,
      :process_percent_system, :wifi_network, :wifi_signal, :wifi_noise, :cpu_temp_in_c]

    COMMANDS = ([:device_attributes, :polled_attributes]+DEVICE_ATTRIBUTES+POLLED_ATTRIBUTES).freeze

    attr_accessor :updates_per_second
    attr_accessor *DEVICE_ATTRIBUTES

    attr_accessor :network_send_rate, :network_recv_rate, :cpu_percent_user, 
      :cpu_percent_system, :cpu_percent_idle, :gc_rate, :process_percent_user,
      :process_percent_system, :swap_in_rate, :swap_out_rate, :cpu_temp_in_c, 
      :wifi_network, :wifi_noise, :wifi_signal

    OSX_SYSTEM_PROFILER = '/usr/sbin/system_profiler'
    OSX_AIRPORT = '/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport'

    IWLIST = "/sbin/iwlist"
    CPU_TEMP_PATHS = Dir.glob("/sys/devices/platform/coretemp.*/temp*_input").sort

    def initialize(params={})
      super params

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

      # CPU Temp:
      @cpu_temp_in_c = File.read(CPU_TEMP_PATHS[0]).to_i / 1000 if CPU_TEMP_PATHS.length > 0

      # Wifi stats:
      if airport?
        airport_out = `#{OSX_AIRPORT} -I`

        @wifi_network = ('"%s" Ch. %s (%s)' % ['SSID','channel','link auth'].collect{|v| 
          osx_command_parse airport_out, v })
        @wifi_noise = osx_command_parse airport_out, 'agrCtlNoise'
        @wifi_signal = osx_command_parse airport_out, 'agrCtlRSSI'
      else
        iwlist_out = `#{IWLIST} #{@primary_interface} scan`

        ssid = (/ESSID:\"([^\"]+)/.match iwlist_out) ? $1 : nil
        channel = (/Frequency:(.+)$/.match iwlist_out) ? $1 : nil

        @wifi_network = '"%s" %s' % [ssid, channel]
        @wifi_signal = (/Signal level=([^ ]+)/.match iwlist_out) ? $1 : nil
        @wifi_noise = (/Quality=([^ ]+)/.match iwlist_out) ? $1 : nil
      end

    end

    def serial_number
      # Serial Number (system)
      @serial_number ||= if system_profiler?
        system_profiler('Serial Number \(system\)')
      else
        # The only way to get a good one seems to be via dmidecode, and I'd 
        # rather not run as root here.
        'N/A' 
      end
    end

    def cpu_arch
      @cpu_arch ||= if system_profiler?
        '%s (%sx) %s %s' % ['Model Identifier', 'Total Number of Cores', 'Processor Name', 
          'Processor Speed'].collect{|for_value| system_profiler(for_value)}
      else
        cpus = File.read('/proc/cpuinfo').scan(/(.+?)\n\n/m)

        '(%sx) %s' % [cpus.length, /model name[^:]:[ ]*(.+)$/.match(cpus[0][0]) ? $1 : nil]
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
      @has_airport ||= File.exists? OSX_AIRPORT
    end

    def osx_command_parse(output, for_value)
      $1 if /^[ ]*#{for_value}:[ ]*(.+)/.match(output)
    end
  end
end
