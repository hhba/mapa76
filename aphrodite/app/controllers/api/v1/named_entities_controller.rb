class Api::V1::NamedEntitiesController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    verify_params!
    ne = Document.find(params[:document_id]).
      named_entities.find(params[:id])
    respond_with({id: ne.id, text: ne.text})
  end

private

  def verify_params!
    unless params[:document_id] && params[:id]
      raise(ActiveResource::BadRequest, "Bad parameters")
    end
  end
end
