class Api::V2::DocumentsController < Api::V2::BaseController
  skip_before_filter :verfy_authenticity_token, only: [:create]

  def index
    @documents = current_user.documents
  end

  def create
    files = params[:document].fetch(:files, [])
    files.each do |file|
      document = Document.new
      document.original_filename = file.original_filename
      document.file = file.path
      current_user.documents << document
      document.save
    end
    render nothing: true, status: 201
  end

  def destroy
    removed = if params[:id]
      document = current_user.documents.find(params[:id])
      remove(document)
    else
      document_ids.all? { |id| remove(current_user.documents.find(id))}
    end

    if removed
      render nothing: true, status: :no_content
    else
      render nothing: true, status: :bad_request
    end
  end

  def status
    @documents = current_user.documents.reject { |d| d.percentage == 100.0 }
  end

  def show
    @document = current_user.documents.find(params[:id])
  end

  def flag
    document = current_user.documents.find(params[:id])
    FlaggerService.new(current_user, document).call
    render nothing: true, status: :no_content
  end

private

  def remove(document)
    JobsService.not_working_on?(document) && document.destroy
  end
end
