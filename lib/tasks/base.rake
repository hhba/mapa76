desc "Fire up console"
task :console do
  require "pry"
  binding.pry
end
