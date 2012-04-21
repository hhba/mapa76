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
  field :state,            type: String, default: "waiting"

  has_many :milestones
  has_many :named_entities
  has_and_belongs_to_many :people
  embeds_many :paragraphs

  validates_presence_of :original_file

  #after_create :split, :analyze
  attr_accessor :sample_mode

  DOCUMENT_STATES = %w(waiting preprocessing processing processed)

  def content
    self.paragraphs.map(&:content).join(".\n")
  end

  # Split original document data and extract metadata and content as clean,
  # plain text for further analysis.
  #
  def split
    # Replace title with original title from document
    logger.info { "Extract title from '#{self.original_file_path}'" }
    self.title = Splitter.extract_title(self.original_file_path)

    logger.info { "Generate a thumbnail from the first page of the document" }
    self.thumbnail_file = Splitter.create_thumbnail(self.original_file_path,
      :output => File.join(Padrino.root, 'public', THUMBNAILS_DIR)
    )

    logger.info { "Extract plain text" }
    text = Splitter.extract_plain_text(self.original_file_path)

    logger.info { "Split into paragraphs and save them" }
    text.split(".\n").each do |paragraph|
      # Because Analyzer is configured to flush buffer at every linefeed,
      # replace all possible '\n' inside paragraphs to avoid a bad sentence split.
      paragraph = paragraph.strip.gsub("\n", ' ')
      self.paragraphs << Paragraph.new(:content => paragraph) if not paragraph.empty?
    end

    save
  end

  # Returns text extracted from paragraphs
  # It allow :from and :to params (should be integers)
  def text(option = {})
    max = self.paragraphs.length
    from = option.has_key?(:from) ? option[:from].to_i : 0
    to = option.has_key?(:to) ? option[:to].to_i : max
    output = ""
    self.paragraphs[from..to].each do |p|
      output << p.content + "\n"
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

  def process_names
    groups = Coreference.resolve(self.people_found)
    groups.each_with_index do |group, index|
      Person.all.each do |known_person|
        if Coreference.search_matching_groups(group, known_person)
          known_person.named_entities << group
        else
          store_name(group)
        end
      end
    end
    self
  end

  def store_name(group)
    person = Person.new(:name => group.first.to_s)
    person.documents << self
    person.named_entities << group
    person.save
  end

  # Perform a morphological analysis and extract named entities like persons,
  # organizations, places, dates and addresses.
  #
  # From the detected entities, create Person instances and try to resolve
  # correference, if possible.
  #
  def analyze
    Analyzer.extract_named_entities(self.content).each do |ne_attrs|
      self.named_entities.push(NamedEntity.new(ne_attrs))
    end
    self.information = {
      :people => people_found.size,
      :dates => dates_found.size,
      :organizations => organizations_found.size
    }
    self.last_analysis_at = Time.now
    save
  end

  def processed?
    self.state == DOCUMENT_STATES.last
  end
end
