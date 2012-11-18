require_relative "register"

class FactRegister < Register
  field :person_ids, type: Array
  field :place_id,   type: BSON::ObjectId
  field :date_id,    type: BSON::ObjectId
  field :action_ids, type: Array
  field :passive,    type: Boolean

  belongs_to :fact
  belongs_to :document

  references [:people, :place, :date, :actions], type: Citation

  validates :person_ids, presence: true
  validates :action_ids, presence: true

  def self.timeline_json
    all.map { |fr| fr.timeline_json }.reject { |fr| !fr }.to_json
  end

  def timeline_json
    unless date.blank? or people.blank? or place.blank?
      { order: date.timestamp, character: people.first.text, group: place.text }
    end
  end
end