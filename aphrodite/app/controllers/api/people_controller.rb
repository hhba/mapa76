class Api::PeopleController < ApplicationController
  def show
    render :json => Person.find(params[:id]).metainfo.to_json
  end
end
