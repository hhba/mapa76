require 'elasticsearch'

module Mapa76
  class Application < Rails::Application
    options = YAML.load_file(File.join(Rails.root, "config", "elasticsearch.yml"))[Rails.env]
    logger = Logger.new(File.expand_path(options["log"], Rails.root))
    host = options["url"]
    config.elasticsearch_client = Elasticsearch::Client.new host: host, logger: logger
    config.elasticsearch_prefix = options["index_prefix"]
  end
end
