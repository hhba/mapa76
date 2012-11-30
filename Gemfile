source :rubygems

gem "activesupport", :require => false
gem "bson_ext"
gem "capistrano"
gem "capistrano-ext"
gem "httpi"
gem "mongoid"
gem "mongoid-pagination"
gem "rake"
gem "rvm-capistrano"
gem "log4r"

group :development, :test do
  gem "debugger"
  gem "pry", :require => false
end

group :test do
  gem "minitest", "~> 2.6.0", :require => "minitest/autorun"
  gem "shoulda-context"
  gem "factory_girl"
  gem "database_cleaner"
  gem "guard"
  gem "guard-minitest"
end

group :workers do
  gem "freeling-analyzer", :git => "git://github.com/munshkr/freeling-analyzer-ruby.git"
  gem "amatch"
  gem "docsplit"
  gem "geokit"
  gem "multi_json"
  gem "nokogiri"
  gem "oj"
  gem "resque"
end
