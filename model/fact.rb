class Fact
  include Mongoid::Document
  include Mongoid::Timestamps

  has_many :registers, class_name: "FactRegister"
end
