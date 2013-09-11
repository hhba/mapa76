class CoreferenceResolutionTask < Base
  @queue = :coreference_resolution_task

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :solving_coreference
    document.resolve_coreference
    document.update_attribute :state, :finished
    document.update_attribute :percentage, 100
  end
end
