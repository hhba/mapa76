class FactRegister < Register
  field :person,  type: NamedEntity
  field :place,   type: NamedEntity
  field :date,    type: NamedEntity
  field :action,  type: ActionEntity
  field :passive, type: Boolean

  belongs_to :fact
  belongs_to :document
end
