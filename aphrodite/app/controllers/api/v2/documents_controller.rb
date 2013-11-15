class Api::V2::DocumentsController < Api::V2::BaseController
  def index
    @documents = current_user.documents
  end

  def destroy
    document = current_user.documents.find(params[:id])
    if JobsService.not_working_on?(document)
      document.destroy
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :bad_request
    end
  end
end
