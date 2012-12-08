task :environment do
  require File.expand_path("../../../config/boot.rb", __FILE__)
end

desc "Fire up console"
task :console => :environment do
  require "pry"

  Pry.config.prompt = [
    proc { "mapa76> " },
    proc { "      | " }
  ]

  binding.pry(:quiet => true)
end
