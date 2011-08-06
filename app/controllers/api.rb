Alegato.controllers :api do
  get :person, :with => [:id], :provides => [:html,:json] do
    p = {}
    if params[:id].to_i == 0
      data = Person.filter_by_name(params[:id])
    else
      data = Person[params[:id]]
    end
    p[:include] = [:milestones] if params[:milestones]
    case content_type
      when :json then data.to_json(p)
    end
  end
  post :person, :with => [:id], :provides => [:html,:json] do
    halt 400, "Missing set param" unless params[:set]
    if params[:id].to_i == 0
      person = Person.filter_by_name(params[:id])
    else
      person = Person[params[:id]]
    end
    if person
      new_milestone = params[:set].delete(:milestone)
      person.set(params[:set])
      if new_milestone
        person.add_milestone(Milestone.new(new_milestone))
      end
      person.save.to_json
    end
  end

  get :milestone, :with => [:id], :provides => [:html,:json] do
    p = {}
    data = Milestone[params[:id]]
    p[:include] = [:person] if params[:person]
    case content_type
      when :json then data.to_json(p)
    end
  end
  post :milestone, :with => [:id], :provides => [:html,:json] do
    halt 400, "Missing set param" unless params[:set]
    milestone = Milestone[params[:id]]
    if milestone
      milestone.set(params[:set])
      milestone.save.to_json
    end
  end
  get :milestones, :with => [:doc_id], :provides => [:html,:json] do
    p = {}
    data = Document[params[:doc_id]].milestones
    case content_type
      when :json then data.to_json(p)
    end
  end

end
