PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
ENV["RACK_ENV"] = PADRINO_ENV

require File.expand_path('../../config/boot', __FILE__)
require 'test/unit'
require 'database_cleaner'

class Test::Unit::TestCase
  include Rack::Test::Methods
  include FactoryGirl::Syntax::Methods

  FactoryGirl.find_definitions

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  def app
    Alegato.tap { |app|  }
  end
end

def data_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), "data", filename))
end
