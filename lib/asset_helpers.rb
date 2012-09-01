module AssetHelpers
  ##
  # Returns the path to the specified asset (css or javascript)
  #
  # @param [String] source_file
  #   The path to the asset (relative or absolute).
  #
  # @return [String] Path for the asset given the +source+.
  #
  def asset_path(source_file)
    if asset = AssetPipeline.environment[source_file]
      asset_path = nil
      if PADRINO_ENV == "production" and AssetPipeline.manifest
        asset_path = AssetPipeline.manifest["assets"][source_file]
      end
      asset_path ||= source_file
      path = ""
      path << "#{AssetPipeline.asset_path}/#{asset_path}"
      path
    end
  end

  def asset_paths(kind)
    Enumerator.new do |yielder|
      AssetPipeline.source_files.fetch(kind.to_s).each do |source_file|
        yielder << asset_path(source_file)
      end
    end
  end
end
