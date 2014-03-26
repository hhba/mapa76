ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require 'minitest/rails'
require "minitest-spec-context"
require 'minitest/focus'
require 'minitest/colorize'
require 'mocha/setup'
Dir["#{Rails.root}/test/support/*.rb"].sort.each { |file| require file }

class MiniTest::Unit::TestCase
  def setup
    DatabaseCleaner.clean
  end
end

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods

  class << self
    alias :context :describe
  end

  def setup
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.clean
    @routes = Rails.application.routes
    Tire.index pages_index { delete }
    Tire.index documents_index { delete }
  end

  def teardown
    # Add code that need to be executed after each test
  end

private

  def documents_index
    Rails.application.config.elasticsearch_prefix + "_documents"
  end

  def pages_index
    Rails.application.config.elasticsearch_prefix + "_pages"
  end
end

class ActionController::TestCase
  include Rails.application.routes.url_helpers
  include Devise::TestHelpers
  include Requests::JsonHelpers

  def json
    @json ||= JSON.parse(response.body)
  end

  def authenticate_api(access_token)
    request.env['HTTP_AUTHORIZATION'] = "Token token=\"#{access_token}\""
  end
end
