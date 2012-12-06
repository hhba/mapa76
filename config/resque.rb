require 'resque'

# Taken from config/boot.rb
APP_ENV  = ENV['APP_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(APP_ENV)
APP_ROOT = File.expand_path('../..', __FILE__).gsub(/releases\/[0-9]+/, "current") unless defined?(APP_ROOT)

# Configure Resque
resque_config = YAML.load_file(File.join(APP_ROOT, 'config', 'resque.yml'))
Resque.redis  = resque_config[APP_ENV]
