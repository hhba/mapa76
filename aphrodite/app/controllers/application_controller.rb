class ApplicationController < ActionController::Base
  if Rails.env.production?
    rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found_page
    rescue_from ActionController::RoutingError, with: :not_found_page
    rescue_from RuntimeError, with: :error_page
  end
  protect_from_forgery

private

  def after_sign_in_path_for(resource)
    documents_path
  end

  def hostname
    if request.nil?
      ''
    else
      if request.port == 80
        "#{request.protocol}#{request.host}/"
      else
        "#{request.protocol}#{request.host}:#{request.port}/"
      end
    end
  end

  def only_signed_off
    if current_user
      redirect_to documents_path, notice: 'Ud. ya se ha registrado'
      return
    end
  end

  def current_user_admin
    if current_user.admin?
      current_user
    else
      redirect_to '/', error: 'Authorization denied'
      false
    end
  end

  def not_found_page
    respond_to do |type|
      type.html { render template: 'errors/404', status: 404, layout: 'pretty' }
      type.all  { render :nothing => true, :status => 404 } 
    end
  end

  def error_page
    respond_to do |type|
      type.html { render template: 'errors/500', status: 500, layout: 'pretty' }
      type.all  { render :nothing => true, :status => 404 } 
    end
  end
end
