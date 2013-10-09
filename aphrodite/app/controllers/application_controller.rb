class ApplicationController < ActionController::Base
  protect_from_forgery

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

protected

  def authenticate_admin_user!
    authenticate_user!
    unless current_user.admin?
      redirect_to root_path, error: "Unauthorized access!"
    end
  end
end
