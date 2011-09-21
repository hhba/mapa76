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
  get :people do
    @doc = Document.find(params[:doc_id])
    @people = @doc.people
    render "admin/doc/people"
  end
  get :person, :with => [:id] do
    if params[:id].to_i == 0
      @person = Person.filter_by_name(params[:id]).first
    else
      @person = Person.find(params[:id])
    end
    @what = Milestone.what_list
    @where = Milestone.where_list 
    @doc = Document.find(params[:doc_id])
    person_name = ActiveSupport::Inflector.transliterate(@person.name).downcase
    @fragments = @doc.extract.person_names.find_all{|name| 
      name = ActiveSupport::Inflector.transliterate(name.to_s.downcase)
      name == person_name
    }
    render "admin/doc/person"
  end
  post :person, :with => [:id] do
    person = Person.find(params[:id])
    puts params[:person][:milestones].inspect
    Array(params[:person][:milestones]).each{|idx,milestone|
      data = milestone.dup
      data[:what] = ! data["what_txt"].blank? ? data["what_txt"] : data["what_opc"]
      data.delete("what_txt")
      data.delete("what_opc")
      data[:where] = ! data["where_txt"].blank? ? data["where_txt"] : data["where_opc"]
      data.delete("where_txt")
      data.delete("where_opc")
      #convert dates in spanish into YY-MM-DD
      data["date_from"] = data["date_from"].split(/[-\/]/).reverse.join("-")
      data["date_to"] = data["date_to"].split(/[-\/]/).reverse.join("-")
      if data[:id].to_i > 0
        id = data.delete("id")
        m=Milestone.find(id)
        m.update_attributes(data)
      else
        data.delete("id")
        m=Milestone.new(data)
      end
      person.milestones << m
    }
    person.to_json
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
