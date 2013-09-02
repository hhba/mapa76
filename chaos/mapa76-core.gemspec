# -*- encoding: utf-8 -*-
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "mapa76/core/version"

Gem::Specification.new do |gem|
  gem.name          = "mapa76-core"
  gem.version       = Mapa76::Core::VERSION
  gem.authors       = ["Marcos Vanetta", "Damián Silvani"]
  gem.email         = ["marcosvanetta@gmail.com", "dsilvani@gmail.com"]
  gem.summary       = %q{The core classes of Mapa76}
  gem.description   = %q{Models and classes shared by the Mapa76 webapp
                         and the processing pipeline}
  gem.homepage      = "https://github.com/hhba/mapa76-core"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "mongoid", "~> 3.0.14"
  gem.add_dependency "mongoid-pagination"
  gem.add_dependency "mongoid-grid_fs"
  gem.add_dependency "tire"
  gem.add_dependency "resque"
  gem.add_dependency "yajl-ruby"

  gem.add_development_dependency "minitest"
  gem.add_development_dependency "database_cleaner"
  gem.add_development_dependency "factory_girl"
  gem.add_development_dependency "mocha"
end
