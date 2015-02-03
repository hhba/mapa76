class Api::V2::DateEntitiesController < Api::V2::BaseController
  def index
    @entities = EntitiesProvider.new(current_user, :date_entities).for(get_document_ids)
    @documents = current_user.documents.minimal.to_a
    render 'api/v2/shared/entities'
  end

  def show
    @entity = DateEntity.find(params[:id])
    render 'api/v2/shared/entity'
  end
end
