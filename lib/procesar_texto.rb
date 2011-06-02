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
    @t=t.readlines.map{|l| l.strip.gsub(/\s{2,}/,' ')}.join("\n")
  end
  LETRAS='áéíóúñüa-z'
  LETRASM='ÁÉÍÓÚÑÜA-Z'
    # Palabra Palabra|de|del
  NOMBRES_PROPIOS_RE="(?:[#{LETRASM}][#{LETRAS}]+(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:de|la|del)))*)"
  DIRECCIONES_RE=Regexp.new("(?<![\.] )(?<!^)(#{NOMBRES_PROPIOS_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NOMBRES_PROPIOS_RE}*)")
  def direcciones
    # Nombres propios, seguidos de un numero
    encontrar_con_context(DIRECCIONES_RE)
  end
  def nombres_propios
    encontrar_con_context(Regexp.new("(#{NOMBRES_PROPIOS_RE})"))
  end
  def encontrar_con_context(re)
    next_start = 0
    results = []
    loop do 
      break if not @t.match(re,next_start){|match|
        next_start = match.end(0)
        r = Result.new(match[0].strip,@t,match.begin(0),match.end(0)) 
        results << r
      }
    end
    results
  end
  class Result < String
    attr_accessor :start_pos,:end_pos,:doc
    def initialize(s,doc,start_pos,end_pos)
      @doc=doc
      @start_pos=start_pos
      @end_pos=end_pos
      super(s)
    end
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
  end
  class Direccion < Result
    include Cache
    require "geokit"
    include Geokit::Geocoders
    Geokit::Geocoders::provider_order=[:google]
    require "digest/md5"
    def initialize(*s)
      if not s.first.is_a?(Result)
        super
      else
        s=s.first
        super(s,s.doc,s.start_pos,s.end_pos)
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

