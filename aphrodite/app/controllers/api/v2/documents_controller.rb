# encoding: utf-8

class Api::V2::DocumentsController < Api::V2::BaseController
  skip_before_filter :verfy_authenticity_token, only: [:create]

  def index
    documents = current_user.documents.desc(:created_at).listing.map do |document|
      output = {}
      output[:id] = document.id
      output[:title] = document.title
      output[:created_at] = document.created_at
      output[:url] = document.url
      output[:percentage] = document.percentage
      output[:failed] = !document.valid?
      output[:error_messages] = document.errors.messages
      output[:counters] =   {
        people: document.context_cache.fetch('people', []).count,
        organizations: document.context_cache.fetch('organizations', []).count,
        places: document.context_cache.fetch('places', []).count,
        dates: document.context_cache.fetch('dates', []).count
      }
      output
    end
    respond_with documents
  end

  def links
    uploader = LinksUploaderService.new(params[:bucket], current_user)
    if uploader.valid?
      @documents = uploader.call
      render :index
    else
      render json: {
        error_messages: { files_limit: "Ha excedido el límite de documentos"}
        }, status: 403
    end
  end

  def create
    files = params[:document].fetch(:files, [])
    uploader = DocumentUploaderService.new(files, current_user)
    if uploader.valid?
      @documents = uploader.call
      render :index
    else
      render json: {error_messages: { files_limit: "Ha excedido el límite de documentos"}}, status: 403
    end
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
    @documents = current_user.documents.listing
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
