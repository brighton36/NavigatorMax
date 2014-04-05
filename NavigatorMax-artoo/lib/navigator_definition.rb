require 'psych'

class NavigatorDefinition
  def initialize(path)
    @config = symbolize(Psych.load(File.read(path)))
  end

  def register(robot)
    robot.api @config[:api] if @config.has_key? :api
    @config[:devices].each do |(label, params)|
      robot.device label, params
    end if @config.has_key? :devices
  end

  private

  # This is just an easy helper for use with psych
  def symbolize(obj)
    if obj.kind_of? Hash
      obj.inject({}){|memo,(k,v)| memo.merge({k.to_sym => symbolize(v)})}
    elsif obj.kind_of? Array
      obj.inject([]){|memo,v| memo << symbolize(v); memo}
    else
      obj
    end
  end
end
