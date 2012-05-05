Alegato.controllers :person, :parent => :doc do
  get :index, :map => '/people' do
    @people = Person.all.limit(50)
    @documents = Document.all.to_a

    render 'people/index'
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
    @fragments = @doc.extract.person_names.find_all do |name|
      name = ActiveSupport::Inflector.transliterate(name.to_s.downcase)
      name == person_name
    end

    render "admin/doc/person"
  end

  post :person, :with => [:id] do
    person = Person.find(params[:id])
    puts params[:person][:milestones].inspect
    Array(params[:person][:milestones]).each do |idx, milestone|
      data = milestone.dup
      data[:what] = !data["what_txt"].blank? ? data["what_txt"] : data["what_opc"]
      data.delete("what_txt")
      data.delete("what_opc")
      data[:where] = !data["where_txt"].blank? ? data["where_txt"] : data["where_opc"]
      data.delete("where_txt")
      data.delete("where_opc")
      #convert dates in spanish into YY-MM-DD
      data["date_from"] = data["date_from"].split(/[-\/]/).reverse.join("-")
      data["date_to"] = data["date_to"].split(/[-\/]/).reverse.join("-")
      if data[:id].to_i > 0
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
end
