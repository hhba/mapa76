# Helper methods defined here can be accessed in any controller or view in the application

Alegato.helpers do
  # def simple_helper_method
  #  ...
  # end
  def markup_fragment(fragment)
    fr = fragment.extract()
    ret = fragment.dup
    nombres_propios = fr.nombres_propios
    fechas = fr.fechas
    direcciones = fr.direcciones

    nombres_propios.each{|n|
      ret.gsub!(n,"<span class='name'>#{n}</span>")
    }
    fechas.each{|n|
      ret.gsub!(n.context(0),"<span class='date'>#{n.context(0)}</span>")
    }
    direcciones.each{|n|
      ret.gsub!(n,"<span class='address'>#{n}</span>")
    }
    ret.gsub!("\n","<br />")
    ret
  end
end
