require_relative "register"

class FactRegister < Register
  field :person_ids, type: Array
  field :place_id,   type: BSON::ObjectId
  field :date_id,    type: BSON::ObjectId
  field :action_ids, type: Array
  field :passive,    type: Boolean

  belongs_to :fact
  belongs_to :document

  references [:people, :place, :date, :actions], type: NamedEntity

  validates :person_ids, presence: true
  validates :action_ids,  presence: true
end
