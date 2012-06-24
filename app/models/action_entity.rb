class ActionEntity < NamedEntity
  VERBS = %w(
    detener
    secuestrar
    torturar
    desaparecer
    ver
    violar
    abusar
    nacer
    morir
    encontrar
    transladar
    asesinar
  ).sort

  def self.valid?(attrs)
    VERBS.include?(attrs[:lemma])
  end
end
