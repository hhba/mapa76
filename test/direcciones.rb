require "./lib/procesar_texto.rb"
pt=ProcesarTexto.new(open("data/alegato2.txt"))
#pt.nombres_propios.each{|n| puts n}
puts pt.nombres_propios_re
puts pt.direcciones_re
pt.direcciones.each{|d|
  dir = ProcesarTexto::Direccion.new(d)
  puts "#{dir} #{dir.geocodificar}\n\n"
}

