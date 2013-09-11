class DocumentProcessBootstrapTask
  def self.perform(document_id)
    Resque.enqueue(NormalizationTask, document_id)
  end
end