class CoreferenceResolutionTask < Base
  @queue = :coreference_resolution_task

  def self.perform(document_id)
    document = Document.find(document_id)
    Coreference.resolve(document, document.people_found)
  end
end
