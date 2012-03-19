Alegato.controllers :doc_admin,  :parent => :doc do
  layout :admin
  get :index do
    @doc = Document.find(params[:doc_id])
    @most_mentioned = []
    render "admin/doc/index"
  end
  post :reparse do
    @doc = Document.find(params[:doc_id])
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre|
      @person_names[Person.normalize_name(nombre)] << nombre
    }
    params[:people].each{|n|
      person_name = Person.normalize_name(n)
      p = Person.find_or_create_by(name: n)
      @doc.people << p
    }
    render "admin/doc/reparse_ok.erb"
  end
  get :reparse do
    @doc = Document.find(params[:doc_id])
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre|
      @person_names[Person.normalize_name(nombre)] << nombre
    }
    render "admin/doc/reparse"
  end

  get :milestones do
    @doc = Document.find(params[:doc_id])
    @milestones = @doc.milestones.order_by([:date_from,:desc])
    render "admin/doc/milestones"
  end
  get :milestone, :with => [:id] do
    @doc = Document.find(params[:doc_id])
    @milestone = Milestone.find(params[:id])
    @fragment=@doc.fragment(@milestone.source_doc_fragment_start - 200 ,@milestone.source_doc_fragment_start + 200)

    render "admin/doc/milestone"
  end
  get :hot_zones do
    @doc = Document.find(params[:doc_id])
    @heatmap_people = Heatmap.new(@doc.length)
    @heatmap_dates = Heatmap.new(@doc.length)
    @doc.extract.person_names.each{|nombre| @heatmap_people.add_entry(nombre.start_pos,nombre) }
    @doc.extract.dates.each{|date| @heatmap_dates.add_entry(date.start_pos,date) }
    render "admin/doc/hot_areas"
  end
  get :curate_fragment, :with => [:start,:end] do
    @doc = Document.find(params[:doc_id])
    params[:start] = 0 if params[:start].to_i < 0
    @fragment=@doc.fragment(params[:start].to_i,params[:end].to_i)
    render "admin/doc/curate_fragment"
  end
end
