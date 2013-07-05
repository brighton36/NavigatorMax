#!/usr/bin/env ruby
# encoding: UTF-8

require 'rubygems'
require "sys/cpu"
require 'sys/uptime'
include Sys


def time_method(method=nil, *args)
  beginning_time = Time.now
  if block_given?
    yield
  else
    self.send(method, args)
  end
  end_time = Time.now

  (end_time - beginning_time)*1000
end

puts "Metadata:"

boot_time = Uptime.boot_time.to_s
puts "  * Architecture: " + CPU.architecture
puts "  * Machine: " + CPU.machine
puts "  * Mhz: " + ( (CPU.respond_to?(:cpu_freq)) ? CPU.cpu_freq.to_s : 'Unknown' )
puts "  * Number of cpu's on this system: " + CPU.num_cpu.to_s
puts "  * CPU model: " + CPU.model
puts "  * Boot Time:" + boot_time.inspect

memory_usage = nil
load_avg = nil
uptime = nil
cpu_usage = nil
threads = nil

puts "Poll indicators:"
poll_time = time_method do
  memory_usage = `ps -o rss= -p #{Process.pid}`.to_i # in kilobytes 
  load_avg = CPU.load_avg
  uptime = Uptime.uptime.to_s
  cpu_usage,threads = `top -l 1 -pid #{Process.pid} -stats cpu,threads`.lines.to_a.last.split ' '
end

puts "  * This process memory usage: %s KiB" % memory_usage
puts "  * Load averages: " + load_avg.join(", ")
puts "  * Uptime:" + uptime.to_s
puts "  * CPU usage:" + cpu_usage.to_s
puts "  * Threads:" + threads.to_s
puts "  (Poll Time %s ms)" % poll_time.to_s

puts "TODO! Iowait?"
