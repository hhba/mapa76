class Contact
  include Mongoid::Document

  field :name, type: String
  field :email, type: String
  field :organization, type: String
  field :message, type: String

  validates :name, presence: true
  validates :email, presence: true
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
end