class FactRegister < Register
  # FIXME this should be a helper
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

  # FIXME this should be a helper
  def self.timeline_json
    all.map { |fr| fr.timeline_json }.reject { |fr| !fr }.to_json
  end

  # FIXME this should be a helper
  def timeline_json
    unless date.blank? or people.blank? or place.blank?
      { order: date.timestamp, character: people.first.text, group: place.text }
    end
  end
end
