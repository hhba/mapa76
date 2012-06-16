class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :surname_father,  type: String
  field :searchable_name, type: String
  field :tags,            type: Array
  field :confidence,      type: Float, default: 0.0

  before_save :store_normalize_name

  has_many :milestones
  has_many :named_entities
  has_and_belongs_to_many :documents

  def self.conadep
    Person.all.select { |person| person.tags.include?("conadep")}
  end

  def self.populate(document, duplicates, opt = {})
    output = []
    tags = opt[:tags] ? opt[:tags] : []
    confidence = opt[:confidence] ? opt[:confidence] : 0.0
    duplicates.each do |duplicate|
      puts duplicate.inspect
      already_added = duplicate.collect { |ne| self.where(:name => ne.text).first }.compact
      puts "lo que ya estaba #{already_added.inspect}"
      if already_added.empty?
        person = Person.create :name => duplicate.first.text,
                               :tags => tags,
                               :confidence => confidence
        person.documents << document
        person.named_entities << duplicate
      else
        person = already_added.first
        person.named_entities << duplicate
        person.documents << document
      end
      person.save
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
    { "_id" => _id, "created_at" => created_at, :documents => docs, :full_name => full_name, :tags => tags}
  end

protected

  def store_normalize_name
    self.searchable_name = self.class.normalize_name(name)
  end
end
