class Person < Sequel::Model
  one_to_many :milestones
  many_to_many :documents
end
Person.plugin :json_serializer

