class Relation
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :registers, class_name: "RelationRegister"
end
