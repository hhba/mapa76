require "rubygems" unless defined?(Gem)
require "bundler/setup"

require "mapa76/core"

# Configure Mongoid
Mongoid.load!("spec/mongoid.yml", :test)

# Configure Resque
resque_config = YAML.load_file("spec/resque.yml")
Resque.redis  = resque_config["test"]

# Test dependencies
require "minitest/spec"
require "minitest/autorun"
require "mocha/setup"

begin
  require "turn/autorun"
rescue LoadError
end

require "factory_girl"
require "database_cleaner"


class MiniTest::Unit::TestCase
  include FactoryGirl::Syntax::Methods

  FactoryGirl.find_definitions

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end
