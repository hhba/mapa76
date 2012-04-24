class ExtractionTask
  @queue = :extraction

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :extracting
    document.analyze
    Resque.enqueue(CoreferenceResolutionTask, document_id)

    if document.addresses_found.count > 0
      Resque.enqueue(GeocodingTask, document_id)
    end
  end
end
