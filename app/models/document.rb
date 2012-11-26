# encoding: utf-8
require 'splitter'
require 'csv'

class Document
  include Mongoid::Document
  include Mongoid::Timestamps
  include Finder

  field :title,            type: String
  field :heading,          type: String
  field :category,         type: String
  field :published_at,     type: Date
  field :description,      type: String
  field :original_file,    type: String
  field :thumbnail_file,   type: String
  field :information,      type: Hash
  field :fontspecs,        type: Hash
  field :last_analysis_at, type: Time
  field :processed_text,   type: String
  field :app,              type: Symbol, :default => :mapa76
  field :state,            type: Symbol, :default => :waiting

  has_many :milestones
  has_many :named_entities
  has_many :pages
  has_many :fact_registers
  has_and_belongs_to_many :people, index: true

  validates_presence_of :original_file

  after_create :enqueue_process
  attr_accessor :sample_mode, :people_count


  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire do
    mapping do
      indexes :_mid, :index => :not_analyzed
      indexes :title, :analyzer => "snowball", :boost => 100
      indexes :pages, :analyzer => "snowball"
    end
  end

  BLOCK_SEPARATOR = ".\n"

  def lang
    self.app == :mapa76 ? :es : :en
  end

  def to_csv
    heading = %w(name, fuerza, etiqueta)
    CSV.generate do |csv|
      csv << heading
      people.each do |person|
        csv << [person.name, person.force, person.tags.inspect]
      end
    end
  end

  def resolve_coreference
    Coreference.resolve(self, self.people_found)
    self
  end

  # TODO option for a range of pages
  def text(options={})
    self.pages.sort_by(&:num).map(&:text).join(Page::SEPARATOR)
  end

  def context
    {
      id: self.id,
      registers: self.fact_registers.map(&:to_hash),
      people: self.people.map { |person| { id: person.id, name: person.full_name, mentions: person.mentions_in(self) } },
      dates: self.dates_found.group_by(&:text).map { |k, v| { text: k, mentions: v.size} },
      organizations: self.organizations_found.group_by(&:text).map { |k, v| { text: k, mentions: v.size} },
      places: (self.places_found + self.addresses_found).group_by(&:text).map { |k, v| { text: k, mentions: v.size} },
    }
  end

  def indication
    output = []
    self.paragraphs.each do |p|
      output << p.content[0..40]
    end
    output
  end

  def original_file_path
    File.join(Padrino.root, 'public', DOCUMENTS_DIR, self.original_file) if self.original_file
  end

  def _dump(level)
    id.to_s
  end

  def self._load(arg)
    self.find(arg)
  end

  # deprecated
  def length
    fd { |fd| fd.read.size }
  end

  def re_analyze
    self.named_entities.destroy_all
    analyze
  end

  def processed?
    self.state == :finished
  end

  def readable?
    state_to_percentage > 10
  end

  def has_geocoded_addresses?
    self.addresses_found.where(:lat.ne => nil, :lng.ne => nil).count > 0
  end

  def state_to_percentage
    {
      :waiting => 0,
      :normalizing => 10,
      :analyzing_layout => 20,
      :extracting => 40,
      :solving_coreference => 90,
      :finished => 100
    }[self.state]
  end

  def build_index
    output = []
    self.paragraphs.each_with_index do |p, index|
      output << { :first_words => p.first_words, :paragraph_id => p.id, :number => index + 1 }
    end
    output
  end

  def total_paragraphs
    self.paragraphs.count
  end

  def total_pages
    (total_paragraphs / 20.0).ceil
  end

  def page(page = 1)
    self.paragraphs.paginate(:page => page)
  end

  def last_page?(page=1)
    page == total_pages
  end

  def new_iterator
    DocumentIterator.new(self)
  end

  def to_indexed_json
    fields = {
      _mid: id.to_s,
      title: title,
      heading: heading,
      pages: {},
    }
    pages.each do |page|
      fields[:pages][page.num] = page.text
    end
    fields.to_json
  end

protected
  def enqueue_process
    Resque.enqueue(NormalizationTask, self.id)
    return true
  end
end
