class Person
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :searchable_name, type: String
  field :tags,            type: Array
  field :confidence,      type: Float, default: 0.0

  before_save :store_normalize_name

  has_many :milestones
  has_many :named_entities
  has_and_belongs_to_many :documents

  def self.conadep
    Person.all.collect { |person| person.tags.includes?("conadep")}
  end

  def mentions_in(doc)
    "TODO"
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
      self.named_entities.collect { |ne| ne.original_text.downcase }
    else
      [self.name.downcase]
    end
  end

protected

  def store_normalize_name
    self.searchable_name = self.class.normalize_name(name)
  end
end
