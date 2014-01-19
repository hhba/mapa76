module EntitiesHelper
  def document_title(id, documents)
    documents.detect { |d| d.id.to_s == id}.title
  end
end