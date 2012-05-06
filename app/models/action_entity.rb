class ActionEntity < NamedEntity
  def self.valid?(attrs)
    [ 'ver',
      'secuestrar',
      'violar',
      'torturar'
    ].include?(attrs[:lemma])
  end
end
