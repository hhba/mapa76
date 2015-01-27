rails_root = Rails.root || File.dirname(__FILE__) + '/../..'
rails_env = Rails.env || 'development'

resque_config = YAML.load(
  ERB.new(File.read(Rails.root.join('config', 'resque.yml'))).result
)
Resque.redis = resque_config[rails_env]
