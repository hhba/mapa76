require "./lib/procesar_texto.rb"
pt=ProcesarTexto.new(open("data/alegato2.txt"))
#pt.nombres_propios.each{|n| puts n}
pt.direcciones.each{|d|
  dir = ProcesarTexto::Direccion.new(d)
  puts "#{dir}:\n #{dir.context(100)}\n\n"
}

