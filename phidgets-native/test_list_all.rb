#!/usr/bin/env ruby
# encoding: UTF-8

require './lib/phidgets_native.bundle'

#Phidget.enable_logging! :verbose

puts "Using Library version: "+Phidget::LIBRARY_VERSION

# Here's the definition of our table:
Column = Struct.new :label, :width, :attr

columns = [ %w(# 3), %w(Serial\ No. 10 serial_number), %w(Type 20 type), 
  %w(Class 30 device_class), %w(Name 30 name), %w(Version 8 version),
].collect{|args| Column.new(*args)}

# Calculate the table visual elements:
end_cap,separator = %w( +%s+ |%s|).collect{|fmt| 
  fmt % columns.collect{|col| "-" * (col.width.to_i+4)}.join('|') }
row_fmt = '|- %s -|' % columns.collect{|col| "%-#{col.width}s"}.join(' -|- ')

# Construct the table and Output it:
[ end_cap, row_fmt % columns.collect(&:label), 
  Phidget.all.enum_for(:each_with_index).collect{ |p,i|
  [ separator, 
    row_fmt % columns.collect{|col| (col.attr) ? p.send(col.attr.to_sym) : i } ]
}, end_cap].flatten.each{|line| puts line}
