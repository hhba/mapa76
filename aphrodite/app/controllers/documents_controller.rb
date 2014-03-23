# encoding: UTF-8

class DocumentsController < ApplicationController
  before_filter :authenticate_user!, except: [:export, :download]
  helper_method :sort_column, :sort_direction

  def index
    render layout: 'aeolus'
  end

  def list
    @documents = Document.where(user_id: current_user.id).order_by(order)
  end

  def search
    if params[:q].present?
      params[:ids] = params.fetch(:ids, '').split(',')
      @results = SearcherService.new(current_user).where(params)
      render :index
    else
      redirect_to documents_path, error: 'Debe introducir un término a buscar'
    end
  end

  def new
    @document = Document.new
  end

  def create
    files = params[:document].fetch(:files, [])
    files.each do |file|
      @document = Document.new
      @document.original_filename = file.original_filename
      @document.file = file.path
      current_user.documents << @document
      @document.save
    end
    redirect_to :action => :index
  end

  def link
    link_service = LinkService.new(params[:document][:link], current_user)
    if link_service.call
      redirect_to documents_path, notice: 'El archivo ha sido linkeado'
    else
      render :new, error: 'Hay un problema con el link'
    end
  end

  def show
    @document = Document.find(params[:id])
    render layout: 'aeolus'
  end

  def status
    render :json => current_user.documents.map { |d| view_context.status(d) }
  end

  def context
    document = Document.find(params[:id])
    render :json => document.context
  end

  def comb
    @document = Document.find(params[:id])
    @pages = @document.pages.asc(:_id).first
    @empty_pages = @document.pages.asc(:_id).only(:id, :num, :width, :height)
    @addresses = @document.addresses_found.select { |addr| addr.geocoded? }
    @center = @addresses.first
    @data_attributes = {document_id: @document.id}
  end

  def download
    # TODO check if dumping to a temp file and sending that file is more
    # memory-efficient...
    @document = Document.find(params[:id])
    send_data @document.file.data, filename: @document.original_filename
  end

  def flag
    document = Document.find(params[:id])
    FlaggerService.new(current_user, document).call
    redirect_to documents_path, notice: "#{document.title} ha sido reportado"
  end

  def generate_thumbnail
    @document = Document.find(params[:id])

    # Create thumbnail file in public assets directory
    path = File.join(Rails.root, "public", request.path)
    if not File.exists?(path)
      File.open(path, "wb") do |fd|
        @document.thumbnail_file.each do |chunk|
          fd.write(chunk)
        end
      end
    end

    # FIXME For now, use #send_file, ideally this should be handled by the
    # assets server (e.g. nginx).
    send_file path, type: "image/png", disposition: "inline"
  rescue Mongoid::Errors::DocumentNotFound
    render :text => nil, :status => 404
  end

  def export
    ids = params.fetch(:ids, []).split(',')
    documents = Document.find(ids)
    exporter = CSVExporterService.new documents, hostname
    cls = params[:class]
    if %w{ people dates places organizations }.include?(cls)
      send_data exporter.public_send("export_#{cls}"),
                type: 'text/csv',
                filename: "analiceme_#{cls}_#{Time.now.to_i}.csv"
    end
  rescue Mongoid::Errors::DocumentNotFound
    render text: nil, status: 404
  end

  def destroy
    document = current_user.documents.find(params[:id])
    if JobsService.not_working_on?(document)
      document.destroy
      redirect_to documents_path, notice: "#{document.title} has been removed"
    else
      redirect_to documents_path, error: "#{document.title} can't be removed now"
    end
  end

private

  def order
    "#{sort_column} #{sort_direction}"
  end

  def sort_column
    %w[created_at title].include?(params[:sort]) ? params[:sort] : 'created_at'
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end
end
