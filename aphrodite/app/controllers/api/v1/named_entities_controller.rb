class Api::V1::NamedEntitiesController < Api::V1::BaseController
  before_filter :authenticate_user!

  def show
    respond_with {}
  end

private

  def entity_finder(type)
  end
end
