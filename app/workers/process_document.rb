class ProcessDocument
  @queue = :processing_document
  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, "preprocessing"
    document.split
    document.analyze
    document.update_attribute :state, "processing"
    document.process_names
    document.update_attribute :state, "processed"
  end
end
