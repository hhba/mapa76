#encoding: utf-8
require 'digest/md5'
require 'geokit'

require File.join(File.expand_path(File.dirname(__FILE__)), 'classifiable')
require File.join(File.expand_path(File.dirname(__FILE__)), 'cacheable')
require File.join(File.expand_path(File.dirname(__FILE__)), 'incomplete_date')


class StringDocument < String
  attr_accessor :id

  alias :read :to_s
end


class Text

  include Cacheable

  attr_reader :doc

  def initialize(doc,offset_start=0,offset_end=-1)
    @cache_id = ''
    if doc.respond_to?(:id)
      @doc_id = doc.id
      @cache_id = "#{@doc_id}:#{offset_start}-#{offset_end}"
      self.cache_enabled = true
    else
      doc = StringDocument.new(doc.to_s)
      doc.id = "?"
      @doc_id = doc.id
    end

    @doc = doc

    @offset_start = offset_start
    @offset_end = offset_end
  end

  def text
    @text ||= if @doc.respond_to?(:read)
      @doc.read
    elsif @doc.respond_to?(:join)
      @doc.join("\n")
    else
      @doc.to_s
    end
  end

  def marshal_dump
    [@doc_id, @cache_id, @doc, @offset_start, @offset_end]
  end

  def marshal_load(a)
    @doc_id, @cache_id, @doc, @offset_start, @offset_end = a
  end


  LETRAS  = 'áéíóúñüça-z'
  LETRASM = 'ÁÉÍÓÚÑÜA-Z'

  # Palabra Palabra|de|del
  NOMBRES_PROPIOS_RE = "(?:[#{LETRASM}][#{LETRAS}#{LETRASM}]{2,}(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= [#{LETRASM}])))){1,})"
  NOMBRE_PROPIO_RE   = "(?:[#{LETRASM}][#{LETRAS}]+(?:[ ,](?:[#{LETRASM}][#{LETRASM}#{LETRAS}]+|(?:(?:de|la|del)(?= ))))*)"

  DIRECCIONES_RE = Regexp.new("(?<!^)((?:Av.? )?#{NOMBRE_PROPIO_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NOMBRE_PROPIO_RE}*)")

  MESES = %w{enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
  MESES_RE = "(?:#{MESES.join("|")})"

  FECHAS_RE = Regexp.new("(?<![0-9])(?<day>[0-9]{1,2})? *[º°]? *(?:del?)? *\\b(?<month>#{MESES_RE})\\b *(?:del?)? *´?(?<year>(20([01][0-9])|19[0-9]{2}|[0-9]{2})?(?![0-9]))|(?<day>[123]?[0-9])[-/](?<month>[01]?[0-9])([-/](?<year>20([01][0-9])|19[0-9]{2}|[0-9]{2}))?", Regexp::IGNORECASE)


  def dates
    res = cache_fetch("dates_#{@cache_id}") do
      find(FECHAS_RE)
    end

    res.map do |date|
      d = date.match(FECHAS_RE)
      day = d["day"].to_i
      if MESES.index(d["month"])
        month = MESES.index(d["month"]) + 1
      else
        month = d["month"].to_i
      end
      year = d["year"].to_i
      if year > 0 and year < 100
        year += 1900
      end

      # at least 2 values must be filled (day-month, month-year)
      if (year > 0 and month > 0) or (day > 0 and month > 0)
        day = nil if day == 0
        begin
          DateWithContext.new_with_context([year, month, day], date.text, date.start_pos, date.end_pos, @doc)
        rescue ArgumentError
          nil
        end
      else
        nil
      end
    end.compact
  end

  def addresses(other=nil)
    # Nombres propios, seguidos de un numero
    cache_fetch("addrs_#{@other.to_s}_#{@cache_id}") do
      a = find(DIRECCIONES_RE).map { |d| Text::Address.new_from_string_with_context(d) }

      if other and other.length > 0
        re = Regexp.new(other.compact.map(&:strip).find_all { |p| p.length > 0 }.join("|"))
        a += find(re).map { |d| Text::Address.new_from_string_with_context(d) }
      end
      a
    end
  end

  def person_names
    cache_fetch("person_names_#{@cache_id}") do
      find(Regexp.new("(#{NOMBRES_PROPIOS_RE})"), PersonName)
    end
  end

  def to_s
    text[@offset_start ... @offset_end]
  end

  def debug
    STDERR.write("#{Time.now} - #{yield}\n") if ENV['DEBUG']
  end

  def find(re, t=Result)
    if @offset_start > 0 || @offset_end > -1
      debug { "Find in fragment: #{@offset_start} ... #{@offset_end}" }
      @searchable_fragment ||= text[@offset_start ... @offset_end]
    else
      debug { "Finding in the whole text #{@offset_start} ... #{@offset_end}" }
      @searchable_fragment ||= text
    end
    debug { "Searching #{re}" }
    results = []
    start_pos = 0
    loop do
      break if not @searchable_fragment.match(re,start_pos) do |match|
        debug { "-#{match[0]}- starts at char #{match.begin(0)}" }
        result = t.new_with_context(match[0].strip,
                                    nil,
                                    match.begin(0) + @offset_start,
                                    match.end(0) + @offset_start,
                                    @doc)
        results << result
        start_pos = match.end(0)
        match
      end
    end

    debug { "Finished, got #{results.length} res" }
    results
  end

  def title_tree
    titles = titles()
    return [] if titles.empty?
    level_bullet = []
    level_bullet[0] = find_title_bullet_type(titles.first)
    curr_level = 0
    titles.map do |title|
      title_bullet = find_title_bullet_type(title)
      title_level = level_bullet.index(title_bullet)
      debug { "Title (#{title}) has bullet #{title_bullet} - level: #{title_level}" }
      if not title_level
        curr_level += 1
        level_bullet[curr_level] = title_bullet
      else
        curr_level = title_level
      end
      [curr_level, title]
    end
  end

  def titles
    res = cache_fetch("titles_#{@cache_id}") do
      find(/\r?\n[^a-z0-9A-Z]*?\r?\n\s*(.*[#{LETRAS}#{LETRASM}]+.*)\s*$/)
        .each { |t| t.gsub!(/^[^a-z0-9A-Z]+/,''); t.strip! }
        .find_all { |t| t.length < 80 }
    end.compact
  end

  def title_for(fragment_or_pos)
    fragment_pos = fragment_or_pos.start_pos rescue fragment_or_pos
    tree = title_tree()
    title_idx = nil
    prev_title_idx = nil
    tree.each.with_index do |level_title, index|
      level, title = level_title
      debug { "Title: #{title} starts at #{title.start_pos}. Looking for the last one before #{fragment_pos}" }
      if title.start_pos > fragment_pos # ya se pasó
        title_idx = prev_title_idx
        break
      else
        prev_title_idx = index
      end
    end
    ret = []
    return ret if not title_idx

    debug { "The closest title is #{title_idx}" }
    min_level = tree[title_idx].first + 1
    title_idx.downto(0) do |idx|
      debug { "Title #{idx} level #{tree[idx].first}" }
      if tree[idx].first < min_level
        ret << tree[idx].last
        min_level -= 1
      end
      break if min_level <= 0
    end
    ret.reverse
  end

  BULLET_ROMAN  = /^(?<bullet>[ivx]+)(?<separator>[^a-z0-9])/i
  BULLET_ARABIC = /^(?<bullet>[0-9]+)(?<separator>[^a-z0-9]?)/i
  BULLET_NONE   = /./

  def find_title_bullet_type(title)
    [BULLET_ROMAN, BULLET_ARABIC, BULLET_NONE].find { |re| title.match(re) }
  end

  module Context
    module InstanceMethods
      def new_with_context(s, custom_text, start_pos, end_pos, doc)
        o = new(*Array(s))
        o.doc = doc
        o.custom_text = custom_text
        o.start_pos = start_pos
        o.end_pos = end_pos
        o
      end
    end

    def fragment_id
      "frag:doc=#{doc.id}:#{start_pos}-#{end_pos}"
    end

    alias :id :fragment_id
    attr_accessor :start_pos,:end_pos,:doc,:custom_text

    def text
      @custom_text || doc.read
    end

    def context(length=50)
      context_start = start_pos - length
      context_end = end_pos + length

      context_start = 0 if context_start < 0
      context_end = text.length if context_end > text.length

      ret = text[context_start ... context_end]
      # debug { "Creating context from #{context_start} - #{context_end}" }
      StringWithContext.new_with_context(ret, text, context_start, context_end, doc)
    end

    def extract
      doc_str = StringDocument.new(text || doc.read)
      doc_str.id = doc.id
      new_doc = Text.new(doc_str, start_pos, end_pos)
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
    include Geokit::Geocoders

    Geokit::Geocoders::provider_order=[:google]

    def self.new_from_string_with_context(*s)
      if not s.first.is_a?(Result)
        s.first.gsub!(/, *$/,"")
        new_with_context(*s)
      else
        s = s.first
        s.gsub!(/, *$/, "")
        new_with_context(s, s.custom_text, s.start_pos, s.end_pos, s.doc)
      end
    end

    def geocode(place="Ciudad de Buenos Aires, Argentina")
      no_dirs  = ['Batallón', 'Convención', 'El ', 'Tenía', 'Legajo ', 'Destacamento ', 'Decreto ', 'En ', 'Ley ', 'Tenia ', 'Tratado ', 'Eran ', 'Grupo de ', 'Conadep ', 'Desde la','Fallos ','Comisaria ','Puente ','Entre ', 'Cabo ', 'Peugeot ']
      return nil if no_dirs.find { |pref| self.start_with?(pref) }
      return nil if self.index(/de [0-9]{1,2}/)
      dir = self
      if self.split(/[0-9],?+/).length == 1
        #no incluye localidad
        dir = "#{self}, #{place}"
      end
      self.cache_enabled = true
      r = cache_fetch("address_#{dir}") do
        MultiGeocoder.geocode(dir)
      end
      r.success && r
    end
  end
end
