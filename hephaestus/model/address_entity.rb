# encoding: utf-8

class AddressEntity < NamedEntity
  include Geokit::Geocoders

  Geokit::Geocoders::provider_order = [:google]

  def geocode(place="Ciudad de Buenos Aires, Argentina")
    no_dirs = [
      'Batallón',
      'Cabo ',
      'Comisaria ',
      'Conadep ',
      'Convención',
      'Decreto ',
      'Desde la',
      'Destacamento ',
      'El ',
      'En ',
      'Entre ',
      'Eran ',
      'Fallos ',
      'Grupo de ',
      'Legajo ',
      'Ley ',
      'Peugeot ',
      'Puente ',
      'Tenia ',
      'Tenía',
      'Tratado ',
    ]

    dir = self.text

    return nil if no_dirs.find { |pref| dir.start_with?(pref) }
    return nil if dir.index(/de [0-9]{1,2}/)

    if self.text.split(/[0-9],?+/).size == 1
      # No incluye localidad
      dir = "#{dir}, #{place}"
    end

    geoloc = MultiGeocoder.geocode(dir)

    if geoloc and geoloc.success
      self.lat, self.lng = [geoloc.lat, geoloc.lng]
      geoloc
    end
  end
end
