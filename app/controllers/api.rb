Alegato.controllers :api do
  get :documents, :with => :id, :provides => [:json] do
    if params[:page].nil?
      document = Document.find(params[:id])
      document.to_json
    else
      document = Document.find(params[:id])
      document.page(params[:page]).to_json(:methods => :named_entities)
    end
  end

  post :classify_name, :map => '/api/classify_name' do
    r = false
    if params[:name] and params[:training]
      Text::PersonName.train(params[:training], params[:name])
      r = Text::PersonName.training_save
    end
    r.to_json
  end

  post :milestones, :map => '/api/milestones' do
    @milestone = Milestone.new params[:event]
    if @milestone.save
      { :saved => true }.to_json
    else
      { :saved => false }.to_json
    end
  end

  get :person, :with => [:id], :provides => [:html, :json] do
    p = {}
    data = Person.find(params[:id])

    if params[:milestones] # poor man's data.to_json(:include => :milestones) which do not seems to work..
      hash = data.attributes
      hash[:milestones] = data.milestones.map(&:attributes)
      data = hash
    end

    case content_type
      when :json then data.to_json(p)
    end
  end

  post :registers, :provides => :json do
    Register.create(JSON.parse(request.body.read.to_s))
  end

  get :documents_states do
    Document.all.collect { |doc| doc.state_to_percentage }.to_json
  end

  get :document_index, :map => "/api/:id/document_index", :provides => :json do
    document = Document.find(params[:id])
    document.build_index.to_json
  end

  get :paragraph, :map => "/api/documents/:document_id/paragraphs/:page", :provides => :json do
    document = Document.find(params[:document_id])
    {
      :paragraphs => document.page(params[:page]).map { |p| { :id => p._id, :content => paragraph_with_tagged_named_entities(p) } },
      :document_id => params[:document_id],
      :current_page => params[:page].to_i,
      :last_page => document.last_page?(params[:page].to_i)
    }.to_json
  end

  get :people, :map => "/api/people/:id", :provides => :json do
    Person.find(params[:id]).to_json
  end

  get :person, :map => "/api/:document_id/people/:id", :provides => :json do
    Person.find(params[:id]).to_json
  end

  get :named_entity, :map => "/api/named_entities/:id", :provides => :json do
    NamedEntity.find(params[:id]).with_context.to_json
  end

end
