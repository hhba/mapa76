class Blacklist
  include Mongoid::Document

  field :text, type: String
  has_many :named_entities

  validates_presence_of :text

  def self.add(person)
    blacklist = find_or_initialize_by text: person.full_name
    person.named_entities.each { |ne| blacklist.named_entities << ne }
    blacklist
  end
end
