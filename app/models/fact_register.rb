class FactRegister < Register
  field :person_id, type: Moped::BSON::ObjectId
  field :place_id,  type: Moped::BSON::ObjectId
  field :date_id,   type: Moped::BSON::ObjectId
  field :action_id, type: Moped::BSON::ObjectId
  field :passive,   type: Boolean

  belongs_to :fact
  belongs_to :document

  references [:person, :place, :date, :action], type: NamedEntity
end
