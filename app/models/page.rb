class Page
  include Mongoid::Document

  field :num,       type: Integer
  field :width,     type: Integer
  field :height,    type: Integer

  has_many    :named_entities
  belongs_to  :document
  embeds_many :text_lines
end
