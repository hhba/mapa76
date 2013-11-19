class Api::V2::BaseController < ApplicationController
  rescue_from ActiveResource::BadRequest, with: :bad_request
  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
  before_filter :restrict_access, except: [:options]
  before_filter :set_headers
  respond_to :json

  def options
    render nothing: true, status: 200
  end

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

  def set_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match,Authorization,Document-Ids'
    headers['Access-Control-Max-Age'] = '86400'
  end

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

