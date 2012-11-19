require_relative "register"

class RelationRegister < Register
  field :subject_register_id,    type: BSON::ObjectId
  field :complement_register_id, type: BSON::ObjectId

  belongs_to :relation
  belongs_to :document

  references [:subject_register, :complement_register], type: Register

  validates :subject_register_id,    presence: true
  validates :complement_register_id, presence: true

  after_save :update_fact_register_isolated_attribute

protected
  def update_fact_register_isolated_attribute
    subject_register.set(:isolated, false)
    complement_register.set(:isolated, false)
  end
end
