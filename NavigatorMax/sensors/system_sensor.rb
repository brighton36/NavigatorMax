require "sys/cpu"
require 'sys/uptime'
require 'sys/uname'


class SystemSensor
  include Sys

  DEVICE_ATTRIBUTES = [:hostname, :boot_time, :cpu_arch, :ruby_description]

  attr_accessor *DEVICE_ATTRIBUTES

  def initialize
    @hostname = Uname.uname
    @boot_time = Uptime.boot_time

    @cpu_arch = '%sx %s (%s/%s) at %s' % [CPU.num_cpu, CPU.model, 
      CPU.architecture, CPU.machine, 
      (CPU.respond_to?(:cpu_freq)) ? CPU.cpu_freq : 'Unknown']
    @ruby_description = System::Ruby.description
    # /usr/sbin/system_profiler SPHardwareDataType
  end

  def device_attributes
    Hash[*DEVICE_ATTRIBUTES.collect{|a| [a,self.send(a)]}.flatten]
  end

  def close; end
end
