class Person < Sequel::Model
  one_to_many :milestones
end
