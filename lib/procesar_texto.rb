#encoding: utf-8
require 'json'
module Cache
  CACHE_ENABLED = true
  CACHE_DIR='/tmp/cache/'
  File.exists?(CACHE_DIR) || Dir.mkdir(CACHE_DIR)
  require "fileutils"
  require 'yaml'
  def cache_load(id)
    path = cache_dir(id)
    return :notcached if not File.exists?(path)
    begin
      YAML.load_file(path)
    rescue
      raise
      nil
    end
  end
  def cache_fetch(key)
    return yield if not CACHE_ENABLED
    id = cache_gen_id(key)
    cached=self.cache_load(id)
    if cached == :notcached
      val=yield
      cache_write(id,val)
    else
      cached
    end
  end
  def cache_gen_id(key)
    self.class.name.to_s + key.to_s 
  end
  def cache_dir(id)
    File.join(CACHE_DIR,Digest::MD5.hexdigest(id))
  end
  def cache_write(id,data)
    dir = cache_dir(id)
    begin
      open(dir,'w'){|fd|
        YAML.dump(data,fd)
      }
    rescue
      puts "Cannot dump! #{$!}"
    end
    data
  end
end

class ProcesarTexto
  def initialize(t)
    if t.respond_to?(:readlines)
      lines=t.readlines
    else
      lines = Array(t)
    end
    @t=lines.map{|l| l.strip.gsub(/\s{2,}/,' ')}.join("\n")
  end
  LETRAS='áéíóúñüa-z'
  LETRASM='ÁÉÍÓÚÑÜA-Z'
    # Palabra Palabra|de|del
  NOMBRES_PROPIOS_RE="(?:[#{LETRASM}][#{LETRAS}]{2,}(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= [#{LETRASM}])))){1,})"    
  NOMBRE_PROPIO_RE="(?:[#{LETRASM}][#{LETRAS}]+(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= ))))*)"    
  DIRECCIONES_RE=Regexp.new("(?<![\.] )(?<!^)(#{NOMBRE_PROPIO_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NOMBRE_PROPIO_RE}*)")
=begin
    d << " 3 de diciembre del 77."  
    d << "3 de diciembre del 1977."
    d << "julio del 78"
    d << "6 de diciembre"
    d << "diciembre de 1978"
=end
  MESES = %w{enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
  MESES_RE="(?:#{MESES.join("|")})"
  FECHAS_RE=Regexp.new("((1[0-2]|[0-9])? *(?:del?)? *(#{MESES_RE}) *(?:del?)? *(20([01][0-9])|19[0-9]{2}|[0-9]{2})?(?![0-9]))",Regexp::IGNORECASE)
  def fechas
    res=encontrar_con_context(FECHAS_RE)
    res.map{|date| 
      d = date.match(FECHAS_RE)
      day=d[2].to_i
      month=MESES.index(d[3]) + 1
      year=d[4].to_i
      if year > 0 and year < 100
        year += 1900
      end
      day = 1 if day == 0
      puts "Queda: #{day}/#{month}/#{year}"
      r=Date.civil(year,month,day)
      r
    }
  end

  def direcciones
    # Nombres propios, seguidos de un numero
    encontrar_con_context(DIRECCIONES_RE)
  end
  def nombres_propios
    encontrar_con_context(Regexp.new("(#{NOMBRES_PROPIOS_RE})"))
  end
  def encontrar_con_context(re,t=Result)
    next_start = 0
    results = []
    loop do 
      break if not @t.match(re,next_start){|match|
        next_start = match.end(0)
        r = t.new_with_context(match[0].strip,@t,match.begin(0),match.end(0)) 
        results << r
      }
    end
    results
  end
  module Context
    module InstanceMethods
      def new_with_context(s,doc,start_pos,end_pos)
        o=new(s)
        o.doc=doc
        o.start_pos=start_pos
        o.end_pos=end_pos
        o
      end
    end
    attr_accessor :start_pos,:end_pos,:doc
    def context(length=50)
      context_start = start_pos - length 
      context_start = 0 if context_start < 0
      better_context_start = start_pos
      while (doc[better_context_start - 1] != '.') and (better_context_start > context_start) do
        better_context_start -= 1
      end
      context_start = better_context_start


      context_end = end_pos + length 
      better_context_end = end_pos
      while doc[better_context_end + 1] != '.' and (better_context_end < context_end) do
        better_context_end += 1
      end
      context_end = better_context_end

      doc[context_start .. context_end].strip
    end
    def self.included(m)
      puts "included in #{m}, extending"
      m.extend(InstanceMethods)
    end
  end
  class Result < String
    include Context
  end
  class DateWithContext < Date
    include Context
  end

  class Direccion < Result
    include Cache
    require "geokit"
    include Geokit::Geocoders
    Geokit::Geocoders::provider_order=[:google]
    require "digest/md5"
    def self.new_from_string_with_context(*s)
      if not s.first.is_a?(Result)
        new_with_context(*s)
      else
        s=s.first
        new_with_context(s,s.doc,s.start_pos,s.end_pos)
      end
    end
    def geocodificar(localidad="Ciudad de Buenos Aires, Argentina")
       no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
       return nil if no_dirs.find{|pref| self.start_with?(pref)}
       return nil if self.index(/de [0-9]{1,2}/)
       dir = self
       if self.split(/[0-9],?+/).length == 1 
         #no incluye localidad
         dir = "#{self}, #{localidad}" 
       end
       r=cache_fetch(dir){
         MultiGeocoder.geocode(dir)
       }
       r.success && r
    end
  end
end

