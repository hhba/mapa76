class CoreferenceResolutionTask
  @queue = :coreference_resolution

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :solving_coreference
    document.process_names
    document.update_attribute :state, :finished
  end
end
