#encoding: utf-8
Alegato.controllers  do
  get :index do
    fd=open("data/alegato2.txt", 'r')
    no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
    texto = Text.new(fd)
    matches_ref = texto.addresses.find_all{|t| ! no_dirs.find{|nd| t.start_with?(nd) } }.map{|d| Text::Address.new_from_string_with_context(d)}
    @addresses = matches_ref.sort.uniq
    render 'index', :addresses => @addresses
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
