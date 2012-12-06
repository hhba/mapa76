module Log4rExtension
  DEFAULT_NAME = "@"
end

module Kernel
  def logger(name=nil)
    name ||= Log4rExtension::DEFAULT_NAME
    name = name.to_s
    lg = Log4r::Logger[name]
    if lg.nil?
      lg = Log4r::Logger.new(name)
      lg.outputters = Log4r::Outputter.stdout
    end
    return lg
  end
end
