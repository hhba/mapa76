require File.expand_path('../config/boot.rb', __FILE__)
require 'padrino-core/cli/rake'
require "rake/sprocketstask"
require "yui/compressor"

Rake::SprocketsTask.new do |t|
  t.environment = AssetPipeline.environment
  t.environment.js_compressor = YUI::JavaScriptCompressor.new(AssetPipeline.js_compressor_options || {})
  t.environment.css_compressor = YUI::CssCompressor.new(AssetPipeline.css_compressor_options || {})
  t.output = File.join(PADRINO_ROOT, AssetPipeline.asset_root)
  t.assets = AssetPipeline.source_files.values.flatten
  t.logger = logger
end

PadrinoTasks.init
