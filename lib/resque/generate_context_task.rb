class GenerateContextTask
  @queue = :generate_context

  def self.perform(document_id)
    doc = Document.find(document_id)
    doc.context(force: true)
    doc.percentage = 100
    doc.save
    logger.info "Context generated"
  end
end