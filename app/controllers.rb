#encoding: utf-8
require "unidecoder"
Alegato.controllers  do
  get :index do
    fd=open("data/alegato2.txt", 'r')
    #puts data
    no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
    texto = ProcesarTexto.new(fd)
    matches_ref = texto.direcciones.find_all{|t| ! no_dirs.find{|nd| t.start_with?(nd) } }.map{|d| ProcesarTexto::Direccion.new_from_string_with_context(d)}
    @direcciones = matches_ref.sort.uniq
    render 'index', :direcciones => @direcciones
  end
  get :nombres, :map => "/:doc_id/nombres" do
    @doc = Document.find_by_id(params[:doc_id].to_i)
    @nombres_propios = Hash.new{|hash,key| hash[key]=[]}
    @doc.extract.nombres_propios.each{|nombre| @nombres_propios[nombre.to_s.downcase.to_ascii] << nombre }
    render "listado_nombres"
  end
  get :nombre, :map => "/:doc_id/nombres/:name" do
    @person = Person.where(:name => params[:name].strip).first || Person.new(:name => params[:name].strip)
    doc = Document.find_by_id(params[:doc_id].to_i)
    @fragments = doc.extract.nombres_propios.find_all{|name| name.to_s.downcase.to_ascii == params[:name].to_s.downcase.to_ascii}
    render "persona"
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
  post :person, :map => "/persona/:name" do
    person = Person.where(:name => params[:name].strip).first || Person.create(:name => params[:name].strip)
    Array(params[:milestones]).each{|milestone|
      person.milestone(milestone)      
    }
    params.inspect
  end
  # get :index, :map => "/foo/bar" do
  #   session[:foo] = "bar"
  #   render 'index'
  # end

  # get :sample, :map => "/sample/url", :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   "Maps to url '/foo/#{params[:id]}'"
  # end

  # get "/example" do
  #   "Hello world!"
  # end

  
end
