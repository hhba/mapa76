class AddressEntity < NamedEntity
  field :lat, :type => Float
  field :lng, :type => Float

  def geocoded?
    self.lat and self.lng
  end
end
