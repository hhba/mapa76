ENV["APP_ENV"] = "test"
require File.expand_path("../../config/boot", __FILE__)
require "minitest/autorun"
require "database_cleaner"
require "mocha/setup"


class MiniTest::Spec
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
