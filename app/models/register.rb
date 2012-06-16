class Register
  include Mongoid::Document
  include Mongoid::Timestamps

  field :who,    type: Array
  field :when,   type: Array
  field :where,  type: Array
  field :to_who, type: Array

  belongs_to :document

  ACTION = %w(detener secuestrar torturar desaparecer ver violar abusar nacer morir encontrar)

end
