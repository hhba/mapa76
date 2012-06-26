class TextLine
  include Mongoid::Document

  field :text,        type: String
  field :num,         type: Integer
  field :left,        type: Integer
  field :top,         type: Integer
  field :fontspec_id, type: String

  # Text and location attributes of the processed text
  field :processed_text, type: String
  field :from_pos, type: Integer
  field :to_pos,   type: Integer

  embedded_in :page

  SEPARATOR = "\n"
end
