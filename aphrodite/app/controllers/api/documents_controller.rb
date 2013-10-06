class Api::DocumentsController < ApplicationController
  before_filter :authenticate_user!

  def show
    document = Document.find(params[:id])
    render :json => if params[:page].nil?
      document.attributes.merge(document.context).to_json
    else
      document.pages.where(:num => params[:page]).first.to_json(:methods => :named_entities)
    end
  end

  def destroy
    document = Document.find(params[:id])
    render json: document.destroy
  end
end
