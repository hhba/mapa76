class Register
  include Mongoid::Document
  include Mongoid::Timestamps

  field :who,    type: Array
  field :when,   type: Array
  field :where,  type: Array
  field :to_who, type: Array

  belongs_to :document

  ACTION = %w(detener secuestrar torturar desaparecer ver violar abusar nacer morir encontrar transladar asesinar)

  def self.actions
    ACTION.sort
  end

  def self.build_and_save(values)
    whats = values.delete("what")
    whats.map do |what|
      values["what"] = what
      self.create(values)
    end
  end

end
