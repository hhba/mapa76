ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'database_cleaner'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  # Add more helper methods to be used by all tests here...
  def setup
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
    Document.tire.index.delete
  end
end

class ActionController::TestCase
  include Devise::TestHelpers
end
