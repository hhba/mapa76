require 'active_support/all'

class MentionsFinderTask < BaseTask
  attr_accessor :document, :user, :named_entities
  @queue = "io_queue"
  @msg = "Contando menciones"

  ENTITY_CLASSES = [:organizations, :addresses, :places, :date_entities]

  def initialize(input)
    @metadata = input['metadata']
    @document = Document.find(input['metadata']['document_id'])
    @user = @document.user
  end

  def call
    ENTITY_CLASSES.each do |entity_cls|
      document.send(entity_cls).destroy_all
      find_and_store(entity_cls)
    end
    document.context(force: true)

    @output = {
      'metadata' => metadata
    }
  end

  def find_and_store(entity_cls)
    klass = build_klass(entity_cls)
    dupplicates(entity_cls).each do |dup|
      entity = user.send(entity_cls).where(name: dup[:name]).first
      if entity
        entity.mentions = entity.mentions.merge({document.id.to_s => dup[:size]})
        entity.save
      else
        entity = klass.create name: dup[:name], mentions: { document.id.to_s => dup[:size]}, lemma: dup[:lemma]
        user.send(entity_cls) << entity
      end
      document.send(entity_cls) << entity
      update_named_entities(entity, entity_cls)
    end
  end

  def update_named_entities(entity, entity_cls)
    NamedEntity.where(lemma: entity.lemma, ne_class: clean_cls(entity_cls)).each do |named_entity|
      named_entity.update_attribute :entity_id, entity.id
    end
  end

  def dupplicates(entity_cls)
    named_entities = document.named_entities.where(ne_class: clean_cls(entity_cls)).to_a
    entity_lemmas = named_entities.map(&:lemma)
    entity_lemmas.uniq.map do |entity_lemma|
      same_lemma_named_entities = named_entities.select { |ne| ne.lemma == entity_lemma }
      {
        size: same_lemma_named_entities.count,
        name: same_lemma_named_entities.first.text,
        lemma: same_lemma_named_entities.first.lemma,
      }
    end
  end

  def clean_cls(entity_cls)
    # hack due date class usage
    if entity_cls == :date_entities
      :dates
    else
      entity_cls
    end
  end

  def documents
    @documents ||= user.documents
  end

  def build_klass(ne_class)
    ne_class.to_s.classify.constantize
  end
end
