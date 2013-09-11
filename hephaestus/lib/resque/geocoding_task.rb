class GeocodingTask < Base
  @queue = :geocoding

  def self.perform(document_id)
    document = Document.find(document_id)
    #document.update_attribute :state, :geocoding
    document.addresses_found.each do |address|
      address.geocode if not address.geocoded?
      address.save
    end
  end
end
