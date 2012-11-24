Alegato.controllers :api do
  get :blacklist, :provides => [:json] do
    Blacklist.all.to_json
  end

  get :documents, :with => :id, :provides => [:json] do
    document = Document.find(params[:id])
    if params[:page].nil?
      document.attributes.merge(document.context).to_json
    else
      document.pages.where(:num => params[:page]).first.to_json(:methods => :named_entities)
    end
  end

  get :map, map: "/api/:id/map", :provides => [:json] do
    document = Document.find(params[:id])
    @addresses = document.addresses_found.select { |addr| addr.geocoded? }
    @addresses.collect { |address|
      {
        title: address.text,
        lat: address.lat,
        long: address.lng,
        document_id: document.id,
        document_title: document.title,
        context: address.context
      }}.to_json
  end

  get :context, :map => '/api/:id/context', :provides => [:json] do
    document = Document.find(params[:id])
    document.context.merge(:heading => document.heading).to_json
  end

  get :person, :with => [:id], :provides => [:html, :json] do
    p = {}
    data = Person.find(BSON::ObjectId(params[:id]))

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
    data = JSON.parse(request.body.read).symbolize_keys
    register = {}

    # Create FactRegister in active voice
    # If to_who field is present
    #   Create FactRegister in passive voice
    #   Create Fact using recently created FactRegister
    #   Create RelationRegister with both created FactRegister
    #   Create Relation using created RelationRegister

    begin
      action = ActionEntity.find_or_create_by({
        document_id: data[:document_id],
        lemma: data[:what].strip.downcase
      })

      # Create "subject" fact
      subject_fact = Fact.create!
      # Create "subject" fact register
      subject_fr = FactRegister.create!({
        document_id: data[:document_id],
        person_ids: data[:who],
        place_id: data[:where].first,
        date_id: data[:when].first,
        action_ids: [action.id],
        passive: false,
      })
      subject_fact.registers << subject_fr

      if not data[:to_who].empty?
        # Create "complement" fact
        complement_fact = Fact.create!
        # Create "complement" fact register
        complement_fr = FactRegister.create!({
          document_id: data[:document_id],
          person_ids: data[:to_who],
          place_id: data[:where].first,
          date_id: data[:when].first,
          action_ids: [action.id],
          passive: true,
        })
        complement_fact.registers << complement_fr

        # Create relation
        relation = Relation.create!
        # Create relation register using recently created
        # "subject" and "complement" fact registers.
        relation_register = RelationRegister.create!({
          document_id: data[:document_id],
          subject_register_id: subject_fr.id,
          complement_register_id: complement_fr.id,
        })
        relation.registers << relation_register
      end
    rescue
      response.status = 405
    else
      response.status = 201
      register.to_json
    end
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
    Person.find(params[:id]).metainfo.to_json
  end

  get :person, :map => "/api/:document_id/people/:id", :provides => :json do
    Person.find(params[:id]).to_json
  end

  get :named_entity, :map => "/api/named_entities/:id", :provides => :json do
    NamedEntity.find(params[:id]).with_context.to_json
  end

  post :blacklist, map: "/api/blacklist/:id", :provides => :json do
    Person.find(params[:id]).blacklist.to_json
  end

  get :tweet, :map => "/api/tweet/", :provides => :json do
    Tweet.create(params)
    Analyzer.extract_tagged_tokens(params["text"]).to_json
  end

end
