class Api::V2::OrganizationsController < Api::V2::BaseController
  def index
    @entities = EntitiesProvider.new(current_user, :organizations).for(get_document_ids)
    render 'api/v2/shared/entities'
  end

  def show
    @entity = Organization.find(params[:id])
    render 'api/v2/shared/entity'
  end
end
