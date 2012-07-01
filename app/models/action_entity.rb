class ActionEntity < NamedEntity
  VERBS = %w(
    abusar
    asesinar
    conducir
    desaparecer
    detener
    encontrar
    liberar
    morir
    nacer
    secuestrar
    someter
    torturar
    trasladar
    ver
    violar
  ).sort

  def self.valid?(attrs)
    VERBS.include?(attrs[:lemma])
  end
end
