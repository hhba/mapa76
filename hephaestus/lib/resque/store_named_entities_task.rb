class StoreNamedEntitiesTask < BaseTask
  @queue = "database"
  @msg = "Guardando entidades"

  attr_reader :document

  def initialize(input)
    @document = Document.find(input['metadata']['document_id'])
    @token_groups = input.fetch('data', [[]])
    @metadata = input['metadata']
  end

  def call
    pages = document.pages
    @token_groups.each_with_index do |group, index|
      group.each do |token|
        store_in(pages[index], token) if NamedEntity.valid_token?(token['tag'])
      end
    end
    @output = {
      'data' => {},
      'metadata' => metadata
    }
  end

  def store_in(page, token)
    @output = {}
    pos = token['pos'] + page.from_pos
    # page = find_page(token['pos'])
    named_entity = NamedEntity.create({
      form:  token['form'],
      lemma: token['lemma'],
      tag:   token['tag'],
      prob:  token['prob'],
      text:  token['form'].gsub("_", " "),
      pos:   pos,
      inner_pos: { pid: page.id, from_pos: pos, to_pos: pos + token['form'].length }
    })
    page.named_entities << named_entity
    document.named_entities << named_entity
  end

  def find_page(pos)
    document.pages.detect { |page| page.from_pos <= pos && pos <= page.to_pos }
  end
end
