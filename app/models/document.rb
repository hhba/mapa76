# encoding: utf-8
require 'splitter'

class Document
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title,            type: String
  field :heading,          type: String
  field :category,         type: String
  field :published_at,     type: Date
  field :description,      type: String
  field :original_file,    type: String
  field :thumbnail_file,   type: String
  field :information,      type: Hash
  field :last_analysis_at, type: Time
  field :state,            type: Symbol, default: :waiting

  has_many :milestones
  has_many :named_entities
  has_many :registers
  has_and_belongs_to_many :people

  has_many :pages

  validates_presence_of :original_file

  after_create :enqueue_process
  attr_accessor :sample_mode, :people_count



  # Perform a morphological analysis and extract named entities like persons,
  # organizations, places, dates and addresses.
  #
  def analyze
    Analyzer.extract_named_entities(self.content).each do |ne_attrs|
      ne_klass = case ne_attrs[:ne_class]
        when :addresses then AddressEntity
        when :actions then ActionEntity
        else NamedEntity
      end
      self.named_entities << ne_klass.new(ne_attrs)
    end
    self.information = {
      :people => self.people.count,
      :people_ne => people_found.size,
      :dates_ne => dates_found.size,
      :organizations_ne => organizations_found.size
    }
    self.last_analysis_at = Time.now
    save
  end

  def resolve_coreference
    Coreference.resolve(self, self.people_found)
    self
  end

  def context
    self.paragraphs = []
    self.person_ids = []
    self.people_count = self.people.count
  end

  def content
    self.paragraphs.map(&:content).join(PARAGRAPH_SEPARATOR)
  end

  # Returns text extracted from paragraphs
  # It allow :from and :to params (should be integers)
  def text(option = {})
    max = self.paragraphs.length
    from = option.has_key?(:from) ? option[:from].to_i : 0
    to = option.has_key?(:to) ? option[:to].to_i : max
    output = ""
    self.paragraphs[from..to].each do |p|
      output << p.content + PARAGRAPH_SEPARATOR
    end
    output
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

  def people_found
    self.named_entities.where(:ne_class => :people)
  end

  def dates_found
    self.named_entities.where(:ne_class => :dates)
  end

  def organizations_found
    self.named_entities.where(:ne_class => :organizations)
  end

  def addresses_found
    self.named_entities.where(:ne_class => :addresses)
  end

  def processed?
    self.state == :finished
  end

  def readable?
    state_to_percentage > 10
  end

  def state_to_percentage
    {
      :waiting => 0,
      :normalizing => 10,
      :extracting => 40,
      :solving_coreference => 70,
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

protected
  def enqueue_process
    Resque.enqueue(NormalizationTask, self.id)
    return true
  end
end
