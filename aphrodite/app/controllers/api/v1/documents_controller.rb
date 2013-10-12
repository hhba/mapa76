class Api::V1::DocumentsController < Api::V1::BaseController
  before_filter :authenticate_user!

  def update
    document = current_user.documents.find(params[:id])
    document.update_attributes params[:document]
    respond_with document
  end
end
