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

  has_many :milestones
  has_and_belongs_to_many :people
  embeds_many :named_entities
  embeds_many :paragraphs

  validates_presence_of :original_file

  after_create :split, :analyze

  attr_accessor :sample_mode

  def content
    self.paragraphs.map { |p| p.content }.join("\n")
  end

  # Split original document data and extract metadata and content as clean,
  # plain text for further analysis.
  #
  def split
    # Replace title with original title from document
    self.title = Splitter.extract_title(self.original_file_path)
    self.thumbnail_file = Splitter.create_thumbnail(self.original_file_path,
      :output => File.join(Padrino.root, 'public', THUMBNAILS_DIR)
    )
    text = Splitter.extract_plain_text(self.original_file_path)
    text.split(".\n").each do |paragraph|
      self.paragraphs << Paragraph.new(:content => paragraph) if paragraph != ""
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
    self.named_entities.select { |ne| ne.ne_class == :people }
  end

  def dates_found
    self.named_entities.select { |ne| ne.ne_class == :dates }
  end

  def organizations_found
    self.named_entities.select { |ne| ne.ne_class == :organizations }
  end

  private

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
        :people => self.named_entities.select { |ne| ne.ne_class == :people }.size,
        :dates => self.named_entities.select { |ne| ne.ne_class == :dates }.size
      }
      self.last_analysis_at = Time.now
      save
    end
end
