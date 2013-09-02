require "mongoid"
require "mongoid/pagination"
require "mongoid-grid_fs"
require "tire"
require "active_support/inflections"

Dir["#{File.dirname(__FILE__)}/model/*.rb"].each do |model_path|
  class_name = File.basename(model_path, ".rb").classify.to_sym
  autoload class_name, model_path
end
