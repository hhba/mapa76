module Log4rExtension
  DEFAULT_NAME = "@"

  LEVEL_PER_ENV = {
    development: 0,
    test: 1,
    production: 1,
  }

  OUTPUTTER_PER_ENV = {
    development: Log4r::Outputter.stdout,
    production: Log4r::FileOutputter.new("fileOutputter", {
      filename: File.join(APP_ROOT, "log", "main.log"),
      trunc: false,
    }),
  }
end

module Kernel
  def logger(name=nil)
    name ||= Log4rExtension::DEFAULT_NAME
    name = name.to_s
    log = Log4r::Logger[name]
    if log.nil?
      log = Log4r::Logger.new(name)
      log.level = Log4rExtension::LEVEL_PER_ENV[APP_ENV.to_sym]
      if outputter = Log4rExtension::OUTPUTTER_PER_ENV[APP_ENV.to_sym]
        outputter.formatter = Log4r::PatternFormatter.new(pattern: "[%l] [%c] %d :: %m")
        log.outputters = outputter
      end
    end
    log
  end
end
