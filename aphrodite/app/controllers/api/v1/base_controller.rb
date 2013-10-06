class Api::V1::BaseController < ApplicationController
  rescue_from ActiveResource::BadRequest, with: :bad_request
  respond_to :json

protected

  def bad_request(exception)
    render json: {respond_type: 'ERROR', exception: exception}, status: 400
  end
end
