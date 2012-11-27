require 'yaml'

# Defines our constants
PADRINO_ENV  = ENV["PADRINO_ENV"] ||= ENV["RACK_ENV"] ||= "development"  unless defined?(PADRINO_ENV)
PADRINO_ROOT = File.expand_path('../..', __FILE__).gsub(/releases\/[0-9]+/, "current") unless defined?(PADRINO_ROOT)

$LOAD_PATH << PADRINO_ROOT

# Load our dependencies
require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
require 'csv'
Bundler.require(:default, PADRINO_ENV)

require 'config/resque'
require "lib/asset_pipeline"

require 'config/tire'

##
# Enable devel logging
#
# Padrino::Logger::Config[:production] = { :log_level => :devel }
# Padrino::Logger.log_static = true
#
LOG_FILE = ENV["LOG"] && open(ENV["LOG"], "a")
Padrino::Logger::Config[:development].merge!({
  :log_level => :debug,
  :stream => LOG_FILE || :stdout,
  :format_datetime => '',
  :format_message => '%s%s - %s',
})

Padrino::Logger::Config[:production].merge!({
  :log_level => :info,
  :stream => LOG_FILE || :to_file,
  :format_datetime => '%d/%b/%Y %H:%M:%S',
  :format_message => '%s - [%s] %s',
})

Mongoid.logger = Padrino.logger

##
# Various asset paths
#
DOCUMENTS_DIR  = 'uploads'
THUMBNAILS_DIR = 'thumbs'

##
# Add your before load hooks here
#
Padrino.before_load do
  if PADRINO_ENV == "analiceme"
    I18n.default_locale = :en
  else
    I18n.default_locale = :es
  end
  AssetPipeline.setup!(File.join(PADRINO_ROOT, "config", "sprockets.yml"))
end

##
# Add your after load hooks here
#
Padrino.after_load do
  # Stupid workaround for Item#load to work
  Rails = nil
end

Padrino.load!
