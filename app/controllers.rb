#encoding: utf-8
Alegato.controllers  do
  get :addr do
    fd=open("data/alegato2.txt", 'r')
    no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
    texto = Text.new(fd)
    matches_ref = texto.addresses.find_all{|t| ! no_dirs.find{|nd| t.start_with?(nd) } }.map{|d| Text::Address.new_from_string_with_context(d)}
    @addresses = matches_ref.sort.uniq
    render 'index', :addresses => @addresses
  end
  get :index do
    @persons = params[:ids] ? Person.filter(:id => params[:ids].split(',')) : Person.filter(:id => Milestone.select(:person_id))
    render :query
  end
  get :timeline_json do
    persons = Person.filter(:id => params[:ids].split(","))
    t={}
    t[:dateTimeFormat] = "iso8601"
    t[:"wiki-section"] = "#{persons.map(&:name).join(", ")}"
    t[:events] = persons.map{|p|
      p.milestones.map{|m|
        r={}
        r[:start] = "#{m.date_from_range.begin.iso8601}"
        if m.date_to_range
          r[:end] = "#{m.date_to_range.last.iso8601}"
        end
        r[:durationEvent] = !! (m.date_from_range && m.date_to_range)
        r[:title] = "#{p.name} - #{m.what}"
        r[:description] =  "#{p.name} - #{m.what} - #{m.where}"
        r
      } 
    }.flatten

    t.to_json
  end
end
