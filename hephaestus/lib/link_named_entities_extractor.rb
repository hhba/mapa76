class LinkNamedEntitiesExtractor
  def initialize(document_id)
    @document = Document.find(document_id)
  end

  def call
    entites = @document.people + @document.organizations + @document.places
    @document.pages.each do |page|
      find_entities_in(page, entities)
    end
  end

  def find_entities_in(page, entities)
  end
end
