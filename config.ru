require ::File.dirname(__FILE__) + '/config/boot.rb'

map "/" do
  run Padrino.application
end

if PADRINO_ENV == "production"
  map AssetPipeline.asset_path do
    run Rack::Directory.new(File.join(PADRINO_ROOT, AssetPipeline.asset_root))
  end
else
  map AssetPipeline.asset_path do
    run AssetPipeline.environment
  end
end
