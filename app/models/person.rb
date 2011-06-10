class Person
  include MongoMapper::Document
  key :name, String
  has_many :milestones
end
