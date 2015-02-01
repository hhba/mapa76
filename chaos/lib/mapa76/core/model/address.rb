class Address
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :lemma,           type: String
  field :mentions,        type: Hash, default: {}

  belongs_to :user, index: true
  has_many :named_entities
  has_and_belongs_to_many :documents
end
