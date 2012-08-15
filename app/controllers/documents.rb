# encoding: utf-8
require 'json'
require 'docsplit'
require 'open-uri'
require 'tempfile'
require 'resque'

Alegato.controllers :documents do
  get :index do
    @docs = Document.only(:id, :heading, :state, :thumbnail_file).all
    render "documents/index"
  end

  get :mine, map: '/documents/mine' do
    # Shows only my documents or the ones I marked as mine
    @docs = Document.all
    render "documents/index"
  end

  get :search, :map => '/documents/search' do
    @docs = Document.where(:heading => /#{params[:title]}/i)

    render "documents/index"
  end

  get :new, :map => '/documents/new' do
    render "documents/new"
  end

  put :create do
    filename = store_file(params['file'])
    @doc = Document.create({
      :title => filename,
      :original_file => filename,
    }.merge(params.slice('heading', 'description', 'category')))

    redirect url(:documents, :index)
  end

  get :show, :map => '/documents/:id' do
    @doc = Document.find(params[:id])

    render "documents/show"
  end

  get :comb, :map => '/documents/:id/comb' do
    @doc = Document.find(params[:id])
    @pages = @doc.pages.asc(:_id).first
    @empty_pages = @doc.pages.asc(:_id).only(:id, :num, :width, :height)

    render("documents/comb")
  end

  get :paragraphs, :map => '/documents/:id/paragraphs/:from/:to' do
    @doc = Document.find(params[:id])
    if params[:to]
      {:p => @doc.text(:from => params[:from], :to => params[:to])}.to_json
    else
      {:p => @doc.text(:from => params[:from], :to => params[:from].to_i + 1)}.to_json
    end
  end

  get :people, :map => '/documents/:id/people' do
    @doc = Document.find(params[:id])
    @people = @doc.people

    render "documents/people"
  end

  get :hot_zones, :map => '/documents/:id/hot_zones' do
    @doc = Document.find(params[:id])
    @heatmap_people = Heatmap.new(@doc.length)
    @heatmap_dates = Heatmap.new(@doc.length)
    @doc.extract.person_names.each { |name| @heatmap_people.add_entry(name.start_pos, name) }
    @doc.extract.dates.each { |date| @heatmap_dates.add_entry(date.start_pos, date) }

    render "documents/hot_zones"
  end

  get :curate_fragment, '/documents/:id/curate/:start/:end' do
    @doc = Document.find(params[:id])
    params[:start] = 0 if params[:start].to_i < 0
    @fragment = @doc.fragment(params[:start].to_i, params[:end].to_i)

    render "documents/curate"
  end

  get :map, :map => '/documents/:id/map' do
    @doc = Document.find(params[:id])
    @addresses = @doc.addresses_found.select { |addr| addr.geocoded? }
    @center = @addresses.first

    raise 'No addresses were found!' if @center.nil?

    render 'documents/map'
  end
end
