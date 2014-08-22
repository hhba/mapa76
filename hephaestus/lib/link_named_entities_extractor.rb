class LinkNamedEntitiesExtractor
  def initialize(document_id)
    @document = Document.find(document_id)
  end

  def call
    entites = @document.people + @document.organizations + @document.places
    @document.pages.each do |page|
      entites.each do |entity|
        find_all(page, entity.name).each do |position|
          store(entity, position)
        end
      end
    end
  end

  def store(entity, position)
    NamedEntity.create({
      text: entity.name,
      pos: position[:from_pos],
      inner_pos: position,
      entity_id: entity.id,
      ne_class: entity_class(entity),
      document: @document
    })
  end

  def entity_class(entity)
    case entity.class
    when Person
      :people
    when Organization
      :organizations
    when Place
      :places
    else
      nil
    end
  end

  def find_all(page, substring)
    index = 0
    output = []

    while (pos = page.text.index(substring, index)) do
      output << {
        from_pos: pos,
        to_pos: pos + substring.length,
        pid: page.id.to_s
      }

      index = pos + substring.length
    end
    output
  end
end
