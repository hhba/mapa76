class TextLine
  include Mongoid::Document

  field :num,         type: Integer
  field :from_pos,    type: Integer
  field :to_pos,      type: Integer
  field :text,        type: String
  field :left,        type: Integer
  field :top,         type: Integer
  field :fontspec_id, type: String

  embedded_in :page

  SEPARATOR = "\n"
end
