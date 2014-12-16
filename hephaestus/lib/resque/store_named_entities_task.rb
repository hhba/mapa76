class StoreNamedEntitiesTask < BaseTask
  @queue = "store_named_entities_task"
  @msg = "Storing named entities"

  attr_reader :document, :tokens

  def initialize(input)
    @document = Document.find(input['metadata']['document_id'])
    @tokens = input['data']
    @metadata = input['metadata']
  end

  def call
    tokens.each do |token|
      store(token) if NamedEntity.valid_token?(token['tag'])
    end
  end

  def store(token)
    @output = {}
    pos = token['pos']
    page = find_page(token['pos'])
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

    @output = {
      'data' => {},
      'metadata' => metadata
    }
  end

  def find_page(pos)
    document.pages.detect { |page| page.from_pos <= pos && pos <= page.to_pos }
  end
end
