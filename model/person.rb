# encoding: utf-8

class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :surname_father,  type: String
  field :searchable_name, type: String
  field :jurisdiction,    type: String
  field :force,           type: String
  field :tags,            type: Array
  field :confidence,      type: Float, default: 0.0

  before_save :store_normalize_name
  before_save :unify_tags

  has_many :milestones
  has_many :named_entities
  has_and_belongs_to_many :documents

  scope :searchable_with, lambda { |name| where(searchable_name: normalize_name(name)) }

  def self.conadep
    Person.all.select { |person| person.tags.include?("conadep")}
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

  def self.populate(document, duplicates, opts={})
    # This is a really ugly code, but it works, I'm not gonna change it now!
    tags = opts.fetch :tags, []
    confidence = opts[:confidence] ? opts[:confidence] : 0.0

    output = []
    duplicates.each do |group|
      already_added = group.collect { |ne| searchable_with(ne.text).first }.compact
      if already_added.empty?
        person = Person.create(:name => group.first.text,
                               :tags => tags,
                               :confidence => confidence)
      else
        person = already_added.first
      end
      person.named_entities.concat(group)
      person.documents << document
      person.save!
      output << person
    end
    output
  end

  def mentions_in(doc)
    self.named_entities.select { |ne| ne.document_id == doc.id }.count
  end

  def self.normalize_name(name)
    ActiveSupport::Inflector.transliterate(name.to_s.downcase)
  end

  def self.filter_by_name(name, is_prefix=false)
    #name +="%" if is_prefix
    #self.filter(:searchable_name.like(normalize_name(name)))
    regexp = "^#{normalize_name(name)}"
    regexp << '.*' if is_prefix
    self.where(searchable_name: Regexp.new(regexp))
  end

  def self.get_id_by_name(name)
    person = filter_by_name(name).first
    person.id if person
  end

  def names
    if name.nil?
      self.named_entities.collect { |ne| ne.text.downcase }
    else
      [self.name.downcase]
    end
  end
  
  def full_name
    if self.surname_father.blank?
      self.name
    else
      self.name + " " + self.surname_father
    end
  end

  def metainfo
    docs = self.documents.map { |doc| {id: doc._id, name: doc.heading }}
    {"_id" => _id, "created_at" => created_at, :documents => docs, :full_name => full_name, :tags => tags}
  end

  def blacklist
    # TODO: here we will store who mark this person as blacklisted
    self.delete
    Blacklist.find_or_create_by text: self.full_name
  end

protected

  def store_normalize_name
    self.searchable_name = self.class.normalize_name(name)
  end

  def unify_tags
    tags.uniq! if tags.class == Array
  end
end

