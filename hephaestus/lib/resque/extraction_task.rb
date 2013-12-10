class ExtractionTask < Base
  @queue = :extraction_task

  attr_reader :document, :progress_handler

  def self.perform(document_id)
    new(document_id).call.to_a
  end

  def initialize(id)
    @document = Document.find(id)
    @document.named_entities.destroy_all
    @progress_handler = ProgressHandler.new(document, bound: document.processed_text.split.size)
  end

  def call
    entity_extractor = EntityExtractor.new(document.processed_text)
    address_extractor = AddressExtractor.new(document.processed_text)
    Enumerator.new do |yielder|
      entity_extractor.call.each do |entity|
        if NamedEntity.valid_token?(entity.tag)
          yielder << entity
          store(entity)
        end
        progress_handler.increment_to(entity.pos)
      end
      address_extractor.call.each do |entity|
        yielder << entity
        store(entity)
      end
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

  def find_text(text, regexp, pos=0)
    text.index(regexp, pos)
  end

  def find_page(pos)
    document.pages.detect { |page| page.from_pos <= pos && pos <= page.to_pos }
  end
end
