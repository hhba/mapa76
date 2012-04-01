class Paragraph
  include Mongoid::Document
  field :content, :type => String

  embedded_in :document
end