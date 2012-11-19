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

  def to_hash
    { who:    self.subject_register.people.map(&:text),
      what:   self.subject_register.actions.map(&:lemma).first,
      when:   self.subject_register.date.text,
      where:  self.subject_register.place.text,
      to_who: self.complement_register.people.map(&:text) }
  end

protected
  def update_fact_register_isolated_attribute
    subject_register.set(:isolated, false)
    complement_register.set(:isolated, false)
  end
end
