es_config = YAML.load_file(File.join(Rails.root, "config", "elasticsearch.yml"))
config = es_config[Rails.env]

Tire::Model::Search.index_prefix config["index_prefix"]

Tire.configure do
  logger File.expand_path(config["log"], Rails.root) if config["log"]
  url config["url"] if config["url"]
end
