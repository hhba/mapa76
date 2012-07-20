class RelationRegister < Register
  field :subject_fact,    type: FactRegister
  field :complement_fact, type: Register

  belongs_to :relation
  belongs_to :document
end
