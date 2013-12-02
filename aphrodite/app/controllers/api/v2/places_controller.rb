class Api::V2::PlacesController < Api::V2::BaseController
  def index
    @places = EntitiesProvider.new(current_user, :places).for(get_document_ids)
    @addresses = EntitiesProvider.new(current_user, :addresses).for(get_document_ids)
    @entities = @places + @addresses
    render 'api/v2/shared/entities'
  end
end
