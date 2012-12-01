APP_ENV = "test"# unless defined?(APP_ENV)
require File.expand_path('../../config/boot', __FILE__)
require 'test/unit'
require 'database_cleaner'
require 'turn/autorun'

class Test::Unit::TestCase
  include FactoryGirl::Syntax::Methods

  FactoryGirl.find_definitions

  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end
end

def data_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), "data", filename))
end
