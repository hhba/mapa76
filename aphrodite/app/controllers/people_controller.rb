class PeopleController < ApplicationController
  before_filter :authenticate_user!

  def blacklist
    render :json => Person.find(params[:id]).blacklist
  end
end
