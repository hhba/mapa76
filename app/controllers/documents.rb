# encoding: utf-8
require 'json'
require 'docsplit'
require 'open-uri'
require 'tempfile'
require 'resque'
Dir[Padrino.root + "/app/workers/*.rb"].each {|file| require file }

Alegato.controllers :documents do
  get :index do
    @docs = Document.all

    render "documents/index"
  end

  get :new, :map => '/documents/new' do
    render "documents/new"
  end

  get :search, :map => '/documents/search' do
    @docs = Document.where(:title => params[:title])

    render "documents/index"
  end

  put :create do
    filename = store_file(params['file'])
    @doc = Document.create({
      :title => filename,
      :original_file => filename,
    }.merge(params.slice('heading', 'description', 'category')))
    Resque.enqueue(ProcessDocument, @doc.id)
    redirect url(:documents, :index)
  end

  get :preprocess, :map => '/documents/:id/preprocess' do
    @doc = Document.find(params[:id])
    render "documents/preprocess"
  end

  post :process, :map => '/documents/:id/process' do
    @doc = Document.find(params[:id]).process_names
    redirect url(:documents, :show, :id => @doc.id)
  end

  get :show, :map => '/documents/:id' do
    @doc = Document.find(params[:id])
    @most_mentioned = []

    render "documents/show"
  end

  get :paragraph, :map => '/documents/:id/paragraph/:paragraph_index' do
    @doc = Document.find(params[:id])
    {:p => @doc.text(:from => params[:paragraph_index], :to => params[:paragraph_index].to_i + 1)}.to_json
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

  get :person, :map => '/documents/:id/people/:person_id' do
    if params[:id].to_i == 0
      @person = Person.filter_by_name(params[:person_id]).first
    else
      @person = Person.find(params[:person_id])
    end
    @what = Milestone.what_list
    @where = Milestone.where_list
    @doc = Document.find(params[:id])
    person_name = ActiveSupport::Inflector.transliterate(@person.name).downcase
    @fragments = @doc.extract.person_names.find_all do |name|
      name = ActiveSupport::Inflector.transliterate(name.to_s.downcase)
      name == person_name
    end

    render "documents/person"
  end

  post :person, :map => '/documents/:id/people/:person_id' do
    person = Person.find(params[:person_id])
    puts params[:person][:milestones].inspect
    Array(params[:person][:milestones]).each do |idx, milestone|
      data = milestone.dup
      data[:what] = !data["what_txt"].blank? ? data["what_txt"] : data["what_opc"]
      data.delete("what_txt")
      data.delete("what_opc")
      data[:where] = !data["where_txt"].blank? ? data["where_txt"] : data["where_opc"]
      data.delete("where_txt")
      data.delete("where_opc")
      # convert dates in spanish into YY-MM-DD
      data["date_from"] = data["date_from"].split(/[-\/]/).reverse.join("-")
      data["date_to"] = data["date_to"].split(/[-\/]/).reverse.join("-")
      if data[:person_id].to_i > 0
        id = data.delete("id")
        m = Milestone.find(id)
        m.update_attributes(data)
      else
        data.delete("id")
        m = Milestone.new(data)
      end
      person.milestones << m
    end
    person.to_json
  end

  get :reparse, :map => '/documents/:id/reparse' do
    @doc = Document.find(params[:id])
    @person_names = Hash.new { |hash, key| hash[key] = [] }
    @doc.extract.person_names.each do |name|
      @person_names[Person.normalize_name(name)] << name
    end

    render "documents/reparse"
  end

  post :reparse, :map => '/documents/:id/reparse' do
    @doc = Document.find(params[:id])
    @person_names = Hash.new { |hash, key| hash[key] = [] }

    @doc.extract.person_names.each do |name|
      @person_names[Person.normalize_name(name)] << name
    end

    params[:people].each do |n|
      person_name = Person.normalize_name(n)
      p = Person.find_or_create_by(name: n)
      @doc.people << p
    end

    redirect url_for(:documents, :show, :id => @doc._id)
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

  get :context do
    if params[:fragment_id]
      data = params[:fragment_id].match(/frag:doc=([^:]+):([0-9]+)-([0-9]+)/)
      puts params
      doc_id = data[1]
      pos_start = data[2]
      pos_end = data[3]
    else
      doc_id = params[:doc_id]
      pos_start = params[:start]
      pos_end = params[:end]
    end

    params[:around] ||= 1000

    case params[:action].to_i
    when 1 # more
      pos_start = pos_start.to_i - params[:around].to_i
      pos_start = 0 if pos_start < 0
      pos_end   = pos_end.to_i + params[:around].to_i
    when 2 # less
      pos_start = pos_start.to_i + params[:around].to_i
      pos_start = 0 if pos_start < 0
      pos_end   = pos_end.to_i - params[:around].to_i
    when 3 # down
      pos_start = pos_start.to_i + params[:around].to_i
      pos_end   = pos_end.to_i + params[:around].to_i
    when 4 # up
      pos_start = pos_start.to_i - params[:around].to_i
      pos_start = 0 if pos_start < 0
      pos_end   = pos_end.to_i - params[:around].to_i
    end

    fragment = Document.find(doc_id).fragment(pos_start, pos_end)
    r = {
      :fragment_id => fragment.fragment_id,
      :text => markup_fragment(fragment),
      :prev_fragment_id => params[:fragment_id]
    }.to_json
  end

  get :map, :map => '/documents/:id/map' do
    @doc = Document.find(params[:id])
    no_dirs = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
    matches_ref = @doc.extract.addresses.find_all { |t|
        !no_dirs.find { |nd| t.start_with?(nd) }
      }.map { |d| Text::Address.new_from_string_with_context(d) }
    @addresses = matches_ref.sort.uniq

    render 'documents/map'
  end
end
