class Page
  include Mongoid::Document

  field :num,       type: Integer
  field :width,     type: Integer
  field :height,    type: Integer
  field :fontspecs, type: Hash

  belongs_to  :document
  embeds_many :text_lines
end
