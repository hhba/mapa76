class CoreferenceResolutionTask
  @queue = :coreference_resolution

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :solving_coreference
    document.resolve_coreference
    document.update_attribute :state, :finished
    doc.percentage = 100
  end
end
