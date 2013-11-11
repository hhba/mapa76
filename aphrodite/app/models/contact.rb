class Contact
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :organization, type: String
  field :message, type: String

  validate :name, presence: true
  validate :email, presence: true
end