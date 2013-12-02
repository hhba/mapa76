class Place
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,            type: String
  field :mentions,        type: Hash, default: {}

  belongs_to :user
  has_many :named_entities
  has_and_belongs_to_many :documents
end