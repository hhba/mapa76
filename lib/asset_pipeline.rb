module AssetPipeline
  class << self
    # Load YML file and initialize Sprockets environment
    # Usually called by the bootstrap script (config/boot.rb).
    #
    # @param [String] path the path to the YML config file
    # @param [Hash] options
    #
    def setup!(path, opts={})
      options = YAML.load_file(path)

      options.each do |key, value|
        instance_variable_set("@#{key}", value)
        define_singleton_method(key) do
          instance_variable_get("@#{key}")
        end
      end
    end

    def environment
      return @environment if @environment
      @environment = Sprockets::Environment.new(PADRINO_ROOT)
      self.load_path.each do |path|
        @environment.append_path(path)
      end
      @environment
    end

    def manifest
      return @manifest if @manifest
      @manifest = File.exists?(manifest_path) ? JSON.load(File.open(manifest_path)) : nil
    end

    def manifest_path
      File.join(PADRINO_ROOT, self.asset_root, "manifest.json")
    end
  end
end
