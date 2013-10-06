class Api::V1::NamedEntitiesController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    entity_type
    respond_with {}
  end

private

  def entity_type
    if %w[places organizations dates addresses].include? params[:type]
      params[:type]
    else
      raise ActiveResource::BadRequest, "Bad parameters"
    end
  end
end
