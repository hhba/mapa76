module EntitiesHelper
  def build_mention(id, val, documents)
    if (document = find_document(id, documents))
      {id: id, title: document.title, mentions: val}
    else
      nil
    end
  end

  def find_document(id, documents)
    documents.detect { |d| d.id.to_s == id}
  end
end