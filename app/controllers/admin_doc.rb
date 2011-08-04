Alegato.controllers :doc_admin,  :parent => :doc do
  layout :admin
  get :index do
    @doc = Document[params[:doc_id]]
    @most_mentioned = @doc.person_dataset.order_by(:mentions).reverse.limit(10)
    render "admin/doc/index"
  end
  post :reparse do
    @doc = Document[params[:doc_id]]
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre| 
      @person_names[Person.normalize_name(nombre)] << nombre 
    }
    params[:people].each{|n|
      person_name = Person.normalize_name(n)
      p = Person.find_or_create(:name => person_name)
      @doc.add_person(p,@person_names[person_name].length) # link person and document and update the number of times this person gets mentioned
    }
  end
  get :reparse do
    @doc = Document[params[:doc_id]]
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre| 
      @person_names[Person.normalize_name(nombre)] << nombre 
    }
    render "admin/doc/reparse"
  end
  get :people do
    @doc = Document[params[:doc_id]]
    @people = @doc.person
    render "admin/doc/people"
  end
  get :person, :with => [:id] do
    if params[:id].to_i == 0
      @person = Person.filter_by_name(params[:id]).first
    else
      @person = Person[params[:id]]
    end
    @what = Milestone.what_list
    @where = Milestone.where_list 
    @doc = Document[params[:doc_id]]
    person_name = ActiveSupport::Inflector.transliterate(@person.name).downcase
    @fragments = @doc.extract.person_names.find_all{|name| 
      name = ActiveSupport::Inflector.transliterate(name.to_s.downcase)
      name == person_name
    }
    render "admin/doc/person"
  end
  post :person, :with => [:id] do
    person = Person.where(:name => params[:name].strip).first || Person.create(:name => params[:name].strip)
    Array(params[:person][:milestones]).each{|milestone|
      data = milestone.dup
      data.delete("id")
      data[:what] = ! data["what_txt"].blank? ? data["what_txt"] : data["what_opc"]
      data.delete("what_txt")
      data.delete("what_opc")
      data[:where] = ! data["where_txt"].blank? ? data["where_txt"] : data["where_opc"]
      data.delete("where_txt")
      data.delete("where_opc")
      m=Milestone.new(data)
      person.add_milestone(m) 
    }
    person.save_changes
    params.values.inspect
  end
  get :milestones do
    @doc = Document[params[:doc_id]]
    @milestones = @doc.milestones_dataset.order(:date_from)
    render "admin/doc/milestones"
  end
  get :milestone, :with => [:id] do
    @doc = Document[params[:doc_id]]
    @milestone = Milestone[params[:id]]
    @fragment=@doc.fragment(@milestone.source_doc_fragment_start - 200 ,@milestone.source_doc_fragment_start + 200)

    render "admin/doc/milestone"
  end

end
