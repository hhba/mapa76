Alegato.controllers do
  get :nombres, :map => "/admin/:doc_id/nombres" do
    @doc = Document.find_by_id(params[:doc_id].to_i)
    @person_names = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.person_names.each{|nombre| @person_names[ActiveSupport::Inflector.transliterate(nombre.to_s.downcase)] << nombre }
    render "admin/persons_list"
  end
  get :nombre, :map => "/admin/:doc_id/nombres/:name" do
    @person = Person.where(:name => params[:name].strip).first || Person.new(:name => params[:name].strip)
    doc = Document.find_by_id(params[:doc_id].to_i)
    @fragments = doc.extract.person_names.find_all{|name| ActiveSupport::Inflector.transliterate(name.to_s.downcase) == ActiveSupport::Inflector.transliterate(params[:name].to_s.downcase)}
    render "admin/person"
  end
  get :context do
    if params[:fragment_id]
      data=params[:fragment_id].match(/frag:doc=([0-9]+):([0-9]+)-([0-9]+)/)
      doc_id=data[1]
      pos_start=data[2]
      pos_end=data[3]
    else
      doc_id=params[:doc_id]
      pos_start=params[:start]
      pos_end=params[:end]
    end
    params[:around] ||= 200
    pos_start   = pos_start.to_i - params[:around].to_i
    pos_start   = 0 if pos_start < 0
    pos_end     = pos_end.to_i + params[:around].to_i

    fragment=Document.find_by_id(doc_id).fragment(pos_start,pos_end)
    r={:fragment_id => fragment.fragment_id, :text => markup_fragment(fragment)}.to_json
    r
  end
  post :classify_name, :map => "/admin/name/classify" do
    r=false
    if params[:name] and params[:training]
      Text::PersonName.train(params[:training],params[:name])
      r=Text::PersonName.training_save
    end
    r.to_json
  end
  post :person, :map => "/admin/person/:name" do
    person = Person.where(:name => params[:name].strip).first || Person.create(:name => params[:name].strip)
    Array(params[:milestones]).each{|milestone|
      person.milestone(milestone)      
    }
    params.inspect
  end

end