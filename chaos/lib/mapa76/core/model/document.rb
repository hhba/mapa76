class Document
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Finder

  DOCUMENT_SIZE_LIMIT = 1048576 # Bytes

  field :title,             type: String
  field :url,               type: String
  field :original_filename, type: String
  field :context_cache,     type: Hash,    default: {}
  field :processed_text,    type: String
  field :status,            type: String,  default: ''
  field :status_msg,        type: String,  default: ''
  field :public,            type: Boolean, default: true
  field :percentage,        type: Float,   default: 0
  field :flagger_id,        type: Moped::BSON::ObjectId
  field :file_id,           type: Moped::BSON::ObjectId

  belongs_to :user, index: true

  has_many :pages, dependent: :destroy
  has_many :fact_registers, dependent: :destroy
  has_many :named_entities, dependent: :destroy
  has_and_belongs_to_many :people,        index: true
  has_and_belongs_to_many :organizations, index: true
  has_and_belongs_to_many :addresses,     index: true
  has_and_belongs_to_many :places,        index: true
  has_and_belongs_to_many :date_entities, index: true
  has_and_belongs_to_many :project

  validates_presence_of :file_id, unless: :link_document?
  validates_presence_of :original_filename, unless: :link_document?
  validates :url, :format => URI::regexp(%w(http https)), if: :link_document?
  validate :file_size_limit, on: :create

  before_save :set_default_title, unless: :link_document?
  after_create  :process!
  after_destroy :destroy_gridfs_files

  scope :private_for, ->(user){ where(:user_id => user.id, :public => false) }
  scope :listing, -> { without([
    :processed_text, :named_entity_ids, :person_ids,
    :organization_ids, :place_ids, :date_entity_ids]) }
  scope :minimal, -> { without([
    :processed_text, :named_entity_ids, :person_ids,
    :organization_ids, :place_ids, :date_entity_ids,
    :url, :original_filename, :context_cache]) }

  index({ created_at: -1, user_id: 1}, { unique: true })

  def self.mark_as_failed(id, msg='')
    begin
      document = Document.find(id)
      document.status = 'FAILED'
      document.status_msg = msg
      document.percentage = -1
      document.save
    rescue Mongoid::Errors::DocumentNotFound
      false
    end
  end

  def flagger
    if flagger_id
      User.find(flagger_id)
    else
      nil
    end
  end

  def to_indexed_json
    fields = {
      title: title,
      original_title: original_title,
      pages: {},
      user_id: user_id,
      project_ids: project_ids,
    }
    # pages.each do |page|
    #   fields[:pages][page.num] = page.text.gsub(/<[^<]+?>/, "")
    # end
    fields.to_json
  end

  def file
    if file_id
      Mongoid::GridFS.namespace_for(:documents).get(file_id)
    end
  end

  def file=(file_or_path)
    fs = Mongoid::GridFS.namespace_for(:documents).put(file_or_path)
    self.file_id = fs.id
    fs
  end

  def thumbnail_file
    if thumbnail_file_id
      Mongoid::GridFS.namespace_for(:thumbnails).get(thumbnail_file_id)
    end
  end

  def thumbnail_file=(file_or_path)
    fs = Mongoid::GridFS.namespace_for(:thumbnails).put(file_or_path)
    self.thumbnail_file_id = fs.id
    fs
  end

  def readable?
    true
  end

  def geocoded?
    true
  end

  def exportable?
    true
  end

  def processed?
    true
  end

  def completed?
    percentage == 100
  end

  def failed?
    id and failed_ids.include?(id.to_s)
  end

  # opt[:force] = true
  def context(opt = {})
    if opt[:force] || context_cache == {}
      self.context_cache = context_generator
      save
    end
    self.context_cache
  end

  def process!
    restart_variables
    input = {metadata: { document_id: self.id, url: self.url, document_type: document_type}}
    Resque.enqueue(SchedulerTask, input.to_json)
  end

  def process_text!
    update_attribute :status, 'text_extraction_task-end'
    Resque.enqueue(SchedulerTask, {metadata: { document_id: self.id}}.to_json)
  end

  def link_document?
    !!(self.url && self.url != "")
  end

  def document_type
    if link_document?
      'link_document'
    else
      'file_document'
    end
  end

protected

  def restart_variables
    update_attribute :percentage, 0
    update_attribute :status, ''
  end

  def context_generator
    {
      :id => id,
      :title => title,
      :people => self.people.map { |person| { id: person.id, name: person.full_name, mentions: person.mentions_in(self) } },
      :dates => self.date_entities.map { |date| {id: date.id, name: date.name, mentions: date.mentions[self.id.to_s]}},
      :organizations => self.organizations.map { |org| {id: org.id, name: org.name, mentions: org.mentions[self.id.to_s]}},
      :places => self.places.map { |place| {id: place.id, name: place.name, mentions: place.mentions[self.id.to_s]}}
    }
  end

  def set_default_title
    if self.title.blank?
      self.title = self.original_filename
    end
  end

  def destroy_gridfs_files
    file.destroy if file
  end

  def failed_ids(opts={})
    self.failed_jobs(opts).map do |job|
      job['payload']['args'].first
    end.compact
  end

  def failed_jobs(opts={})
    opts.reverse_merge!({
      :offset => 0,
      :limit => Resque::Failure.count
    })
    [Resque::Failure.all(opts[:offset], opts[:limit])].flatten.compact
  end

  def file_size_limit
    if !owner_is_admin? && file.length > Document::DOCUMENT_SIZE_LIMIT
      errors.add(:file_size, "File exceeds maximum file size")
    end
  end

  def owner_is_admin?
    user && user.admin?
  end
end
