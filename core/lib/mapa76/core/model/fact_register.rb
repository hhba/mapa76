class FactRegister < Register
  field :person_ids, type: Array
  field :place_id,   type: Moped::BSON::ObjectId
  field :date_id,    type: Moped::BSON::ObjectId
  field :action_ids, type: Array
  field :passive,    type: Boolean, default: false
  field :complement_person_ids, type: Array

  belongs_to :fact
  belongs_to :document

  references [:people, :place, :date, :actions, :complement_people], type: Citation

  validates :person_ids, presence: true
  validates :action_ids, presence: true

  def to_hash
    attrs = {
      what:  self.actions.map(&:lemma).first,
      when:  self.date.try(:text),
      where: self.place.try(:text),
    }
    if passive
      attrs.merge!(who: self.complement_people.map(&:text),
                   to_who: self.people.map(&:text))
    else
      attrs.merge!(who: self.people.map(&:text),
                   to_who: self.complement_people.map(&:text))
    end
    attrs
  end

  def self.timeline_json
    all.map { |fr| fr.timeline_json }.reject { |fr| !fr }.to_json
  end

  def timeline_json
    unless date.blank? or people.blank? or place.blank?
      { order: date.timestamp, character: people.first.text, group: place.text }
    end
  end
end
