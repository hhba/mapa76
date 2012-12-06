desc "Fire up console"
task :console do
  require "pry"

  Pry.config.prompt = [
    proc { "mapa76> " },
    proc { "      | " }
  ]

  binding.pry(:quiet => true)
end
