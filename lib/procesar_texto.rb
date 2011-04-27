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
    puts "Cached: #{path} - #{id}"
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
  def letras
    'áéíóúñüa-z'
  end
  def letrasM
    'ÁÉÍÓÚÑÜA-Z'
  end
  def nombres_propios_re
    # Palabra Palabra|de|del
    "(?:[#{letrasM}][#{letras}]+(:?[ ,](:?[#{letrasM}][#{letrasM}#{letras}]+|(?:de|la|del)))*)"
  end
  def direcciones_re
    Regexp.new("(?<![\.] )(?<!^)(#{nombres_propios_re}+ [0-9]{1,5}(?![0-9\/])(,? )?#{nombres_propios_re}*)")
  end
  def direcciones
    # Nombres propios, seguidos de un numero
    re = direcciones_re
    encontrar_con_contexto(re)
  end
  def nombres_propios
    encontrar_con_contexto(Regexp.new("(#{nombres_propios_re})"))
  end
  def encontrar_con_contexto(re)
    next_start = 0
    results = []
    loop do 
      break if not @t.match(re,next_start){|match|
        next_start = match.end(0)
        puts "#{match.begin(0)} - #{match.end(0)} - #{match[0].strip}"
        r = Result.new(match[0].strip) 
        r.contexto = contexto(match.begin(0),match.end(0))
        results << r
      }
    end
    results
  end
  def contexto(comienzo,fin,largo = 100)
        contexto_comienzo = comienzo - largo 
        contexto_comienzo = 0 if contexto_comienzo < 0
        contexto_fin = fin + largo 
        contexto_fin = @t.length if contexto_fin > @t.length
        @t[contexto_comienzo .. contexto_fin]
  end

  class Result < String
    attr_accessor :contexto
  end
  class Direccion < Result
    include Cache
    require "geokit"
    include Geokit::Geocoders
    Geokit::Geocoders::provider_order=[:google]
    require "digest/md5"
    def initialize(s)
      if not s.is_a?(Result)
        super
      else
        self.contexto = s.contexto
        self.replace(s)
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

