class Milestone < Sequel::Model
  many_to_one :person
end
