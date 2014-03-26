class Api::V2::DocumentsController < Api::V2::BaseController
  skip_before_filter :verfy_authenticity_token, only: [:create]

  def index
    @documents = current_user.documents.desc(:created_at)
  end

  def create
    files = params[:document].fetch(:files, [])
    @documents = files.map do |file|
      document = Document.new
      document.original_filename = file.original_filename
      document.file = file.path
      current_user.documents << document
      document.save
      document
    end

    render :index
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
    @documents = current_user.documents
  end

  def show
    @document = current_user.documents.find(params[:id])
  end

  def flag
    document = current_user.documents.find(params[:id])
    FlaggerService.new(current_user, document).call
    render nothing: true, status: :no_content
  end

  def pages
    document = current_user.documents.find(params[:id])
    @pages = document.pages.in(num: get_pages)
  end

  def search
    if params[:q].present?
      render json: SearcherService.new(current_user).where(params[:q], params[:id]).to_json
    else
      render nothing: true, status: :bad_request
    end
  end

private

  def remove(document)
    searcher = SearcherService.new(current_user)
    document.destroy && searcher.destroy_for(document)
  end

  def get_pages
    if request.headers.fetch('HTTP_X_PAGES', []).empty?
      [1, 2, 3, 4, 5]
    else
      request.headers.fetch('HTTP_X_PAGES', []).split(',').map(&:to_i)
    end
  end
end
