class EntitiesExtractionTask < Base
  @queue = :entities_extraction_task

  attr_reader :document

  def self.perform(document_id)
    new(document_id).call
  end

  def initialize(id)
    @document = Document.find(id)
    @document.named_entities.destroy_all
  end

  def call
    pos = 0
    analyzer_client = AnalyzerClient.new(document.processed_text)
    address_extractor = AddressExtractor.new(document.processed_text)
    analyzer_client.tokens.each do |token|
      store(token) if NamedEntity.valid_token?(token.tag)
    end
    address_extractor.call.each do |token|
      store(token)
    end
  end

  def store(token)
    pos = token.pos
    page = find_page(token.pos)
    named_entity = NamedEntity.create({
      form:  token.form,
      lemma: token.lemma,
      tag:   token.tag,
      prob:  token.prob,
      text:  token.form,
      pos:   pos,
      inner_pos: { pid: page.id, from_pos: pos, to_pos: pos + token.form.length }
    })
    page.named_entities << named_entity
    document.named_entities << named_entity
  end

  def find_page(pos)
    document.pages.detect { |page| page.from_pos <= pos && pos <= page.to_pos }
  end
end