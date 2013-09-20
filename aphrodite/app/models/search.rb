class Search
  include Mongoid::Document

  field :term, type: String
  belongs_to :user
end
