class Document
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Finder

  field :title,             type: String
  field :original_title,    type: String
  field :original_filename, type: String
  field :context_cache,     type: Hash,    default: {}
  field :fontspecs,         type: Hash,    default: {}
  field :processed_text,    type: String
  field :status,            type: String,  default: ''
  field :tasks,             type: Array,   default: []
  field :public,            type: Boolean, default: true
  field :percentage,        type: Float,   default: 0
  field :flagger_id,        type: Moped::BSON::ObjectId
  field :file_id,           type: Moped::BSON::ObjectId
  field :thumbnail_file_id, type: Moped::BSON::ObjectId

  belongs_to :user

  has_many :pages, dependent: :destroy
  has_many :fact_registers, dependent: :destroy
  has_many :named_entities, dependent: :destroy
  has_and_belongs_to_many :people,        index: true
  has_and_belongs_to_many :organizations, index: true
  has_and_belongs_to_many :addresses,     index: true
  has_and_belongs_to_many :places,        index: true
  has_and_belongs_to_many :date_entities
  has_and_belongs_to_many :project

  validates_presence_of :file_id
  validates_presence_of :original_filename

  before_save   :set_default_title
  after_create  :process!
  after_destroy :destroy_gridfs_files

  scope :public, -> { where(public: true) }
  scope :private_for, ->(user){ where(:user_id => user.id, :public => false) }
  scope :without, ->(documents){ not_in(_id: documents.map(&:id)) }

  include Tire::Model::Search
  include Tire::Model::Callbacks

  tire do
    mapping do
      indexes :title,          analyzer: "snowball", boost: 100
      indexes :original_title, analyzer: "snowball", boost: 90
      indexes :pages,          analyzer: "snowball"
      indexes :user_id,        index: :not_analyzed
    end
  end

  def self.reindex
    Document.tire.index.delete
    Document.tire.import
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
    Resque.enqueue(DocumentProcessBootstrapTask, id)
  end

protected

  def restart_variables
    update_attribute :percentage, 0
    update_attribute :status, ''
  end

  def context_generator
    ctx = {
      :id => id,
      :title => title,
      :registers => self.fact_registers.map(&:to_hash),
      :people => self.people.map { |person| { id: person.id, name: person.full_name, mentions: person.mentions_in(self) } },
      :dates => self.dates_found.group_by(&:text).map { |k, v| { text: k, mentions: v.size} },
      :organizations => self.organizations_found.group_by(&:text).map { |k, v| { text: k, mentions: v.size} },
      :places => (self.places_found + self.addresses_found).group_by(&:text).map { |k, v| { text: k, mentions: v.size} }
    }

    [:registers, :people, :dates, :organizations, :places].each do |f|
      ctx[:"has_#{f}"] = !ctx[f].empty?
    end

    ctx
  end

  def set_default_title
    if self.title.blank?
      self.title = self.original_filename
    end
  end

  def destroy_gridfs_files
    file.destroy if file
    thumbnail_file.destroy if thumbnail_file
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
end
