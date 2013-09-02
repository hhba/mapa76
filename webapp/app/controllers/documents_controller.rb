class DocumentsController < ApplicationController
  before_filter :authenticate_user!, only: [:create, :new]

  def index
    @page = params[:page] || 1
    @search = Document.tire.search(page: @page, per_page: 10) do |s|
      s.fields :id
      s.query do |q|
        params[:q].blank? ? q.all : q.string(params[:q])
      end
      if params[:mine].to_i == 1
        s.filter :term, user_id: [current_user.id]
      end
      if params[:project_id]
        s.filter :term, project_ids: [params[:project_id]]
      end
      s.highlight :title, *(1..10000).map(&:to_s)
    end
    @results = @search.results.map do |item|
      [item, item.load]
    end
    @projects = current_user ? current_user.projects : []
    @project = Project.find params[:project_id] if params[:project_id]
    @documents_count = Document.count
    @my_documents_count = current_user.documents.count if current_user
  end

  def new
    @document = Document.new
  end

  def create
    file = params[:document].delete(:file)
    @document = Document.new(params[:document])
    @document.original_filename = file.original_filename
    @document.file = file.path

    if @document.save
      redirect_to :action => :index
    else
      #flash[:error] = @document.errors
      redirect_to :back
    end
  end

  def show
    @document = Document.find(params[:id])
  end

  def status
    render :json => Document.all.map { |d| view_context.status(d) }
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
  end

  def download
    # TODO check if dumping to a temp file and sending that file is more
    # memory-efficient...
    @document = Document.find(params[:id])
    send_data @document.file.data, filename: @document.original_filename
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
    exporter = CSVExporterService.new(Document.find(params[:id]))
    cls = params[:class]
    if %w{ people dates places organizations }.include?(cls)
      send_data exporter.public_send("export_#{cls}"),
                type: 'text/csv',
                filename: "#{exporter.original_filename}__#{cls}.csv"
    end
  rescue Mongoid::Errors::DocumentNotFound
    render text: nil, status: 404
  end
end
