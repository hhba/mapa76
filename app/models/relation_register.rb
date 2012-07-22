require_relative "register"

class RelationRegister < Register
  field :subject_register_id,    type: Moped::BSON::ObjectId
  field :complement_register_id, type: Moped::BSON::ObjectId

  belongs_to :relation
  belongs_to :document

  references [:subject_register, :complement_register], type: Register

  validates :subject_register_id,    presence: true
  validates :complement_register_id, presence: true
end
