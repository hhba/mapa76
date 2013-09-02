class Api::DocumentsController < ApplicationController
  def index

  end

  def show
    document = Document.find(params[:id])
    render :json => if params[:page].nil?
      document.attributes.merge(document.context).to_json
    else
      document.pages.where(:num => params[:page]).first.to_json(:methods => :named_entities)
    end
  end
end
