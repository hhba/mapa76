require "json"
require "docsplit"
require "open-uri"
require "tempfile"

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

  get :show, :map => '/documents/:id' do
    @doc = Document.find(params[:id])
    @most_mentioned = []
    render "documents/show"
  end

  put :create do
    puts params
    if (params[:file] and params[:file][:tempfile])
      if params[:url]
        require "httpi"
        req = HTTPI.get(params[:url])
        type = req.headers["Content-type"]
        data = req.body
      elsif params[:file]
        type = params[:file][:type]
        data = params[:file][:tempfile].read
      end

      if type  == "application/pdf"
        text = Docsplit.clean_text(Docsplit.extract_text_from_pdf_str(data))
        title = Docsplit.extract_title_from_pdf_str(data)
      elsif type  == "text/plain"
        text = data
        title = params[:title]
      else
        raise "Unknown filetype: #{type}"
      end
    end
    @doc = Document.new
    @doc.title = title
    @doc.data = text
    if @doc.savedisabled
      redirect url(:documents, :show, :id => @doc.id)
    else
      "Error guardando"
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
    @fragments = @doc.extract.person_names.find_all{|name|
      name = ActiveSupport::Inflector.transliterate(name.to_s.downcase)
      name == person_name
    }
    render "documents/person"
  end

  get :reparse, :map => '/documents/:id/reparse' do
    @doc = Document.find(params[:id])
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each do |name|
      @person_names[Person.normalize_name(name)] << name
    end
    render "documents/reparse"
  end

  post :reparse, :map => '/documents/:id/reparse' do
    @doc = Document.find(params[:id])
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre| 
      @person_names[Person.normalize_name(nombre)] << nombre 
    }
    params[:people].each{|n|
      person_name = Person.normalize_name(n)
      p = Person.find_or_create_by(name: n)
      @doc.people << p
    }
    redirect url_for(:documents, :show, :id => @doc._id)
  end

  post :classify_name do
    r=false
    if params[:name] and params[:training]
      Text::PersonName.train(params[:training],params[:name])
      r=Text::PersonName.training_save
    end
    r.to_json
  end

  get :context do
    if params[:fragment_id]
      data=params[:fragment_id].match(/frag:doc=([^:]+):([0-9]+)-([0-9]+)/)
      puts params
      doc_id=data[1]
      pos_start=data[2]
      pos_end=data[3]
    else
      doc_id=params[:doc_id]
      pos_start=params[:start]
      pos_end=params[:end]
    end

    params[:around] ||= 1000

    case params[:action].to_i
      when 1 # more
          pos_start   = pos_start.to_i - params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i + params[:around].to_i
      when 2 # less
          pos_start   = pos_start.to_i + params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i - params[:around].to_i
      when 3 # down
          pos_start   = pos_start.to_i + params[:around].to_i
          pos_end     = pos_end.to_i + params[:around].to_i
      when 4 # up
          pos_start   = pos_start.to_i - params[:around].to_i
          pos_start   = 0 if pos_start < 0
          pos_end     = pos_end.to_i - params[:around].to_i
    end

    fragment=Document.find(doc_id).fragment(pos_start,pos_end)
    r={:fragment_id => fragment.fragment_id, :text => markup_fragment(fragment), :prev_fragment_id => params[:fragment_id]}.to_json
    r
  end

end
