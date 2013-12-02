require 'active_support/all'

class MentionsFinderTask < Base
  attr_accessor :document, :user, :named_entities
  @queue = :mentions_finder_task

  NE_CLASSES = [:organizations, :addresses, :places]

  def self.perform(document_id)
    self.new(document_id).call
  end

  def initialize(document_id)
    @document = Document.find(document_id)
    @user = @document.user
  end

  def call
    NE_CLASSES.each do |ne_class|
      find_and_store(ne_class)
    end
  end

  def find_and_store(ne_class)
    klass = build_klass(ne_class)
    dupplicates(ne_class).each do |dup|
      entity = user.send(ne_class).where(name: dup[:name]).first
      if entity
        entity.mentions = entity.mentions.merge({document.id.to_s => dup[:size]})
        entity.save
      else
        entity = klass.create name: dup[:name], mentions: { document.id.to_s => dup[:size]}
        user.send(ne_class) << entity
      end
      document.send(ne_class) << entity
    end
  end

  def dupplicates(ne_class)
    named_entities = document.named_entities.where(ne_class: ne_class).to_a
    entity_lemmas = named_entities.map(&:lemma)
    entity_lemmas.uniq.map do |entity_lemma|
      same_lemma_named_entities = named_entities.select { |ne| ne.lemma == entity_lemma }
      {
        size: same_lemma_named_entities.count,
        name: same_lemma_named_entities.first.form
      }
    end
  end

  def documents
    @documents ||= user.documents
  end

  def build_klass(ne_class)
    ne_class.to_s.singularize.capitalize.constantize
  end
end
