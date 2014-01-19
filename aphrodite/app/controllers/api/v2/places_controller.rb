class Api::V2::PlacesController < Api::V2::BaseController
  def index
    @places = EntitiesProvider.new(current_user, :places).for(get_document_ids)
    @addresses = EntitiesProvider.new(current_user, :addresses).for(get_document_ids)
    @entities = @places + @addresses
    @documents = current_user.documents.to_a
    render 'api/v2/shared/entities'
  end

  def show
    begin
      @entity = Place.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound => error
      @entity = Address.find(params[:id])
    end
    render 'api/v2/shared/entity'
  end
end
