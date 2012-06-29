class Page
  include Mongoid::Document

  field :num,      type: Integer
  field :from_pos, type: Integer
  field :to_pos,   type: Integer
  field :width,    type: Integer
  field :height,   type: Integer

  has_many    :named_entities
  belongs_to  :document
  embeds_many :text_lines

  SEPARATOR = "\n"

  def text
    self.text_lines.asc.map(&:text).join(TextLine::SEPARATOR)
  end
end
