class NormalizationTask
  @queue = :normalization

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :normalizing
    document.split
    Resque.enqueue(ExtractionTask, document_id)
  end
end
