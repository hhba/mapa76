class CoreferenceResolutionTask
  @queue = :coreference_resolution

  def self.perform(document_id)
    document = Document.find(document_id)
    document.update_attribute :state, :solving_coreference
    document.resolve_coreference
    document.update_attribute :state, :finished
    doc.percentage = 90
    doc.save

    logger.info "Enqueue Generate Context Task"
    Resque.enqueue(GenerateContextTask, document_id)
  end
end
