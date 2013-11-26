class Page
  include Mongoid::Document

  field :num,      type: Integer
  field :from_pos, type: Integer
  field :to_pos,   type: Integer
  field :width,    type: Integer
  field :height,   type: Integer
  field :text,     type: String

  belongs_to  :document
  has_many :named_entities

  SEPARATOR = "\n"
end
