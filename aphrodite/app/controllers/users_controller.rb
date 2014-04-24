class UsersController < ApplicationController
  layout 'pretty'
  before_filter :authenticate_user!

  def show
    redirect_to edit_user_path(current_user)
  end

  def edit
    @user = current_user
    @project = current_user.projects.first
  end

  def update
    @user = current_user
    @project = current_user.projects.first
    if params[:user]
      @user.update_attributes(params[:user])
    else
      @project.update_attributes(params[:project])
    end

    redirect_to edit_user_path(current_user)
  end
end
