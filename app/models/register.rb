class Register
  include Mongoid::Document
  include Mongoid::Timestamps

  field :who,    type: Array
  field :when,   type: Array
  field :where,  type: Array
  field :to_who, type: Array

  belongs_to :document


  def self.actions
    ActionEntity::VERBS
  end

  def self.build_and_save(values)
    whats = values.delete("what")
    whats.map do |what|
      values["what"] = what
      self.create(values)
    end
  end

  def to_hash
    {
      who:    self.who.map { |w| NamedEntity.find(w).text },
      what:   self.what,
      when:   self.when.map { |w| NamedEntity.find(w).text },
      where:  self.where.map { |w| NamedEntity.find(w).text },
      to_who: self.to_who.map { |w| NamedEntity.find(w).text }
    }
  end
end
