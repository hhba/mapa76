source :rubygems

# Padrino
gem 'padrino'
# Padrino EDGE
# gem 'padrino', :git => 'git://github.com/padrino/padrino-framework.git'

# Project requirements
gem 'rake'

# Component requirements
gem 'activesupport', :require => nil
gem 'capistrano'
gem 'rvm-capistrano'
gem 'capistrano-ext'
gem 'haml'
gem 'httpi'
gem 'mongoid'
gem 'bson_ext'
gem 'mongoid-pagination'

gem 'sprockets'
gem 'yui-compressor', :require => false

gem "tire"
gem "yajl-ruby", :require => "yajl/json_gem"

# NER/NEC analyzers, correference solvers, thumbnail generators, etc
group :workers do
  gem "freeling-analyzer", :git => "git://github.com/munshkr/freeling-analyzer-ruby.git"

  # Splitter
  gem 'docsplit'
  gem "nokogiri"

  # queue
  gem 'resque'

  # Coreference solver
  gem 'amatch'
  gem 'multi_json'
  gem 'oj'

  # Others (geodecoding worker?)
  gem 'geokit'

  # deprecated NER analyzer
  gem 'classifier'
  gem 'madeleine'
  gem 'ruby-stemmer'
end

# Test requirements
group :test do
  gem 'minitest', '~> 2.6.0', :require => 'minitest/autorun'
  gem 'rack-test', :require => 'rack/test'
  gem "shoulda-context"
  gem "factory_girl"
  gem 'database_cleaner'
end

group :development do
  gem 'debugger', :require => 'ruby-debug'
end
