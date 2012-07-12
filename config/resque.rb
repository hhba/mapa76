require 'resque'

# Taken from config/boot.rb
PADRINO_ENV  = ENV['PADRINO_ENV'] ||= ENV['RACK_ENV'] ||= 'development'  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__).gsub(/releases\/[0-9]+/, "current") unless defined?(PADRINO_ROOT)

# Configure Resque
resque_config = YAML.load_file(File.join(PADRINO_ROOT, 'config', 'resque.yml'))
Resque.redis  = resque_config[PADRINO_ENV]
