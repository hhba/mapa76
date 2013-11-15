class Api::V2::DocumentsController < Api::V2::BaseController
  def index
    @documents = current_user.documents
  end

  def destroy
    document = current_user.documents.find(params[:id])
    if remove(document)
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :bad_request
    end
  end

  def destroy_multiple
    if document_ids.all? { |id| remove(Document.find(id))}
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :bad_request
    end
  end

private

  def remove(document)
    JobsService.not_working_on?(document) && document.destroy
  end

  def document_ids
    request.headers['X-Document-Ids'].split(',')
  end
end
