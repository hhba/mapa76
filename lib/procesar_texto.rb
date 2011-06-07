#encoding: utf-8
require 'json'
module Cache
  CACHE_DIR='/tmp/cache_procesar_texto/'
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
  def cache_enabled
    @cache_enabled
  end
  def cache_enabled=(v)
    @cache_enabled=v
  end
  def cache_fetch(key)
    return yield if not cache_enabled
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
  include Cache
  attr_reader :doc
  def initialize(t)
    @cache_id=''
    if t.id
      @cache_id=t.id.to_s
      self.cache_enabled=true
    end
    if t.respond_to?(:read)
      @text = t.read
    elsif t.respond_to?(:join)
      @text = t.join("\n")
    else
      @text = t.to_s
    end
    @doc = t
    true
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
    cache_fetch(@cache_id + "nombres_propios"){
      encontrar_con_context(Regexp.new("(#{NOMBRES_PROPIOS_RE})"))
    }
  end
  def encontrar_con_context(re,t=Result)
    next_start = 0
    results = []
    loop do 
      break if not @text.match(re,next_start){|match|
        next_start = match.end(0)
        r = t.new_with_context(match[0].strip,@text,match.begin(0),match.end(0),@doc) 
        results << r
      }
    end
    results
  end
  module Context
    module InstanceMethods
      def new_with_context(s,text,start_pos,end_pos,doc)
        o=new(s)
        o.doc=doc
        o.text = text
        o.start_pos=start_pos
        o.end_pos=end_pos
        o
      end
    end
    def fragment_id
      if doc.is_a?(Document)
        doc_id = doc.id 
      elsif doc.respond_to?(:path)
        doc_id = doc.path
      else
        doc_id = "?"
      end
      "frag:doc=#{doc_id}:#{start_pos}-#{end_pos}"
    end
    alias :id :fragment_id
    attr_accessor :start_pos,:end_pos,:doc,:text
    def context(length=50)
      context_start = start_pos - length 
      context_start = 0 if context_start < 0
      context_end = end_pos + length 
=begin
      better_context_start = start_pos
      while (doc[better_context_start - 1] != '.') and (better_context_start > context_start) do
        better_context_start -= 1
      end
      context_start = better_context_start


      better_context_end = end_pos
      while doc[better_context_end + 1] != '.' and (better_context_end < context_end) do
        better_context_end += 1
      end
      context_end = better_context_end
=end
      text[context_start .. context_end].strip
      #def new_with_context(s,text,start_pos,end_pos,doc)
      self.class.new_with_context(text[context_start .. context_end].strip,text,context_start,context_end,doc)
    end
    def self.included(m)
      m.extend(InstanceMethods)
    end
  end
  class Result < String
    include Context
  end
  class StringWithContext < String
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
        new_with_context(s,s.text,s.start_pos,s.end_pos,s.doc)
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

