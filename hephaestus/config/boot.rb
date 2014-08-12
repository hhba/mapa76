APP_ENV  = ENV["APP_ENV"] ||= ENV["RAILS_ENV"] ||= "development" unless defined?(APP_ENV)
APP_ROOT = File.expand_path("../..", __FILE__).gsub(/releases\/[0-9]+/, "current") + "/" unless defined?(APP_ROOT)
ENV["RAILS_ENV"] = ENV["MONGOID_ENV"] = APP_ENV

$LOAD_PATH.unshift(APP_ROOT)

require "rubygems" unless defined?(Gem)

require "bundler/setup"
Bundler.require(:default, APP_ENV)

Dotenv.load
require "config/logger"
require "config/database"
require "config/resque"
require "config/tire"

Dir["#{APP_ROOT}/lib/**/*.rb"].sort.each { |file| require file }
Dir["#{APP_ROOT}/model/**/*.rb"].sort.each { |file| require file }

# TODO move these to an YML
DOCUMENTS_DIR  = 'uploads'
THUMBNAILS_DIR = 'thumbs'
