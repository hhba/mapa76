class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :lemma,           type: String
  field :surname_father,  type: String
  field :searchable_name, type: String
  field :jurisdiction,    type: String
  field :force,           type: String
  field :mentions,        type: Hash, default: {}
  field :tags,            type: Array
  field :confidence,      type: Float, default: 0.0

  before_save :store_normalize_name
  before_save :unify_tags

  belongs_to :user, index: true
  has_many :named_entities
  has_and_belongs_to_many :documents, index: true

  scope :searchable_with, lambda { |name| where(searchable_name: normalize_name(name)) }

  def self.normalize_name(name)
    ActiveSupport::Inflector.transliterate(name.to_s.downcase)
  end

  def self.add(name, opt={})
    person = searchable_with(name).first
    if person
      if opt.has_key? :tag
        person.tags << opt[:tag]
        person.save
      end
    else
      opt[:tags] = [opt.delete(:tag)]
      create opt.merge({name: name})
    end
  end

  def full_name
    if self.surname_father.blank?
      self.name
    else
      self.name + " " + self.surname_father
    end
  end

  def mentions_in(doc)
    self.named_entities.select { |ne| ne.document_id == doc.id }.count
  end

  def metainfo
    docs = self.documents.map { |doc| {id: doc._id, name: doc.title }}
    {"_id" => _id, "created_at" => created_at, :documents => docs, :full_name => full_name, :tags => tags}
  end

protected
  def store_normalize_name
    self.searchable_name = self.class.normalize_name(name)
  end

  def unify_tags
    tags.uniq! if tags.class == Array
  end
end
