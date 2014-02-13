require "rake/testtask"

Dir["lib/tasks/*.rake"].each { |r| import r }

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :default => :test
