#encoding: utf-8
require "digest/md5"
require File.join(File.expand_path(File.dirname(__FILE__)),"/classifiable")
require File.join(File.expand_path(File.dirname(__FILE__)),"/cacheable")
require File.join(File.expand_path(File.dirname(__FILE__)),"/incomplete_date")

class String
  #remove invalid utf-8 chars from str
  def tidy_bytes
   self.chars.select{|c| c.valid_encoding?}.join
  end
end
class StringDocument < String
  attr_accessor :id
end

class Text
  include Cacheable
  attr_reader :doc
  def initialize(t)
    @cache_id=''
    if t.respond_to?(:id)
      @doc_id = t.id 
      @cache_id=@doc_id.to_s
      self.cache_enabled=true
    else
      t = StringDocument.new(t.to_s)
      t.id = "?"
      @doc_id = t.id 
    end

    @doc = t

    if t.respond_to?(:read)
      @text = t.read
    elsif t.respond_to?(:join)
      @text = t.join("\n")
    else
      @text = t.to_s
    end
  end
  LETRAS='áéíóúñüa-z'
  LETRASM='ÁÉÍÓÚÑÜA-Z'
  # Palabra Palabra|de|del
  NOMBRES_PROPIOS_RE="(?:[#{LETRASM}][#{LETRAS}]{2,}(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= [#{LETRASM}])))){1,})"    
  NOMBRE_PROPIO_RE="(?:[#{LETRASM}][#{LETRAS}]+(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= ))))*)"    
  DIRECCIONES_RE=Regexp.new("(?<!^)((?:Av.? )?#{NOMBRE_PROPIO_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NOMBRE_PROPIO_RE}*)")
  MESES = %w{enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
  MESES_RE="(?:#{MESES.join("|")})"
  FECHAS_RE=Regexp.new("(?<![0-9])(?<day>[0-9]{1,2})? *°? *(?:del?)? *(?<month>#{MESES_RE}) *(?:del?)? *´?(?<year>(20([01][0-9])|19[0-9]{2}|[0-9]{2})?(?![0-9]))|(?<day>[123]?[0-9])/(?<month>1?[0-9])(/(?<year>20([01][0-9])|19[0-9]{2}|[0-9]{2}))?",Regexp::IGNORECASE)
  def dates
    res=find(FECHAS_RE)
    res.map{|date| 
      d = date.match(FECHAS_RE)
      day=d["day"].to_i
      if MESES.index(d["month"])
        month=MESES.index(d["month"]) + 1
      else
        month = d["month"].to_i
      end
      year=d["year"].to_i
      if year > 0 and year < 100
        year += 1900
      end
      day = nil if day == 0
      begin
        DateWithContext.new_with_context([year,month,day],date.text,date.start_pos,date.end_pos,date.doc)
      rescue ArgumentError
        nil
      end
    }.compact
  end

  def addresses(other=nil)
    # Nombres propios, seguidos de un numero
    a = find(DIRECCIONES_RE).map{|d| Text::Address.new_from_string_with_context(d)}
    if other
      re=Regexp.new(other.compact.map(&:strip).find_all{|p| p.length > 0}.join("|"))
      puts re
      a += find(re).map{|d| Text::Address.new_from_string_with_context(d)}
    end
    a
  end
  def person_names
    cache_fetch("person_names"+Digest::MD5.hexdigest(@text)){
      find(Regexp.new("(#{NOMBRES_PROPIOS_RE})"),PersonName)
    }
  end
  def find(re,t=Result)
    next_start = 0
    next_start_byte = 0
    results = []
    loop do 
      break if not @text.match(re,next_start){|match|
        prev_start_byte = next_start_byte
        prev_start = next_start

        next_start = match.end(0)
        next_start_byte = @text[prev_start ... next_start].bytesize + prev_start_byte 

        curr_start_byte = @text[prev_start ... match.begin(0)].bytesize + prev_start_byte

        r = t.new_with_context(match[0].strip,@text,curr_start_byte,next_start_byte,@doc) 
        results << r
      }
    end
    results
  end
  module Context
    module InstanceMethods
      def new_with_context(s,text,start_pos,end_pos,doc)
        o=new(*Array(s))
        o.doc=doc
        o.text = text
        o.start_pos=start_pos
        o.end_pos=end_pos
        o
      end
    end
    def fragment_id
      "frag:doc=#{doc.id}:#{start_pos}-#{end_pos}"
    end
    alias :id :fragment_id
    attr_accessor :start_pos,:end_pos,:doc,:text
    def context(length=50)
      context_start = start_pos - length 
      context_start = 0 if context_start < 0
      context_end = end_pos + length 
      ret = (context_start ... context_end).map{|pos| text.getbyte(pos).chr }.join.force_encoding("UTF-8").tidy_bytes
      StringWithContext.new_with_context(ret,text,context_start,context_end,doc)
    end
    def extract
      str = StringDocument.new(self.to_s)
      str.id = doc.id
      new_doc = Text.new(str)
      new_doc
    end
    def self.included(m)
      m.extend(InstanceMethods)
    end
  end
  class Result < String
    include Context
  end
  class PersonName < Result
    include Classifiable
  end
  class StringWithContext < String
    include Context
  end
  class DateWithContext < IncompleteDate
    include Context
  end

  class Address < Result
    include Cacheable
    require "geokit"
    include Geokit::Geocoders
    Geokit::Geocoders::provider_order=[:google]
    def self.new_from_string_with_context(*s)
      if not s.first.is_a?(Result)
        s.first.gsub!(/, *$/,"") 
        new_with_context(*s)
      else
        s=s.first
        s.gsub!(/, *$/,"") 
        new_with_context(s,s.text,s.start_pos,s.end_pos,s.doc)
      end
    end
    def geocode(place="Ciudad de Buenos Aires, Argentina")
       no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
       return nil if no_dirs.find{|pref| self.start_with?(pref)}
       return nil if self.index(/de [0-9]{1,2}/)
       dir = self
       if self.split(/[0-9],?+/).length == 1 
         #no incluye localidad
         dir = "#{self}, #{place}" 
       end
       self.cache_enabled = true 
       r=cache_fetch("address_#{dir}"){
         MultiGeocoder.geocode(dir)
       }
       r.success && r
    end
  end
end

