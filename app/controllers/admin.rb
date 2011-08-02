require "json"
Alegato.controllers :admin do
  layout :admin
  get :index do
    @docs = Document.all
    render "admin/doc_list", 
  end
  get :import do
    render "admin/import"
  end
  put :import do
    if params[:text]
      d = Document.new
      d.title = params[:title]
      d.data = params[:text]
      if d.save
        "Guardado ok"
      else
        "Error guardando"
      end
    end
  end
  get :person, :with => [:id] do
    if params[:id].to_i == 0
      @persons = Person.filter_by_name(params[:id]).all
    else
      @persons = [Person[params[:id]]]
    end
    render "admin/person"
  end

  get :context, :with => :fragment_id do
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

    fragment=Document[doc_id].fragment(pos_start,pos_end)
    r={:fragment_id => fragment.fragment_id, :text => markup_fragment(fragment)}.to_json
    r
  end
  post :classify_name do
    r=false
    if params[:name] and params[:training]
      Text::PersonName.train(params[:training],params[:name])
      r=Text::PersonName.training_save
    end
    r.to_json
  end
end
