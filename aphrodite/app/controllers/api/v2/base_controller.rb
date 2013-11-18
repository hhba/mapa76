class Api::V2::BaseController < ApplicationController
  rescue_from ActiveResource::BadRequest, with: :bad_request
  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
  before_filter :restrict_access
  respond_to :json

private

  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
      @current_user = User.where(access_token: token).first
      @current_user
    end
  end

  def current_user
    @current_user
  end

  def document_ids
    request.headers['X-Document-Ids'].split(',')
  end

protected

  def bad_request(exception)
    render json: {respond_type: 'BAD REQUEST'}, status: :bad_request
  end

  def not_found(exception)
    render json: {respond_type: 'NOT FOUND'}, status: :not_found
  end

  def unauthorized(exception)
    render json: {render_type: 'UNAUTHORIZED'}, status: :unauthorized
  end
end

