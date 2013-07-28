#!/usr/bin/env ruby
# encoding: UTF-8


require './lib/ruby_extension_test.bundle'

module Phidget
  class Spatial
    def testing
      "Encouraging!"
    end
  end
end

p = Phidget::Spatial.new(302012);
puts p.testing.inspect
sleep 2
