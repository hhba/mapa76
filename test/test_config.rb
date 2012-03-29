PADRINO_ENV = 'test' unless defined?(PADRINO_ENV)
require File.expand_path('../../config/boot', __FILE__)

class MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    ##
    # You can handle all padrino applications using instead:
    #   Padrino.application
    Alegato.tap { |app|  }
  end
end

def data_path(filename)
  File.expand_path(File.join(File.dirname(__FILE__), "data", filename))
end
