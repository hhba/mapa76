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
    @persons = params[:ids] ? Person.filter(:id => params[:ids].split(',')) : Person.all
    render :query
  end
  get :timeline_json do
    @timelines = Person.filter(:id => params[:ids].split(",")).map{|p|
      p.timeline
    }
    @timelines.to_json
  end
end
