class Document
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Pagination
  include Finder

  field :title,             type: String
  field :category,          type: String
  field :published_at,      type: Date
  field :description,       type: String
  field :original_title,    type: String
  field :original_filename, type: String
  field :context_cache,     type: Hash, default: {}
  field :information,       type: Hash
  field :fontspecs,         type: Hash, default: {}
  field :last_analysis_at,  type: Time
  field :processed_text,    type: String
  field :state,             type: Symbol, default: :waiting
  field :public,            type: Boolean, default: true
  field :percentage,        type: Integer, default: 0
  field :file_id,           type: Moped::BSON::ObjectId
  field :thumbnail_file_id, type: Moped::BSON::ObjectId

  belongs_to :user

  has_many :pages
  has_many :fact_registers
  has_many :named_entities
  has_and_belongs_to_many :people, index: true
  has_and_belongs_to_many :project

  validates_presence_of :file_id
  validates_presence_of :original_filename

  before_save   :set_default_title
  after_create  :enqueue_process
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

  def to_indexed_json
    fields = {
      title: title,
      original_title: original_title,
      pages: {},
      user_id: user_id,
      project_ids: project_ids,
    }
    pages.each do |page|
      fields[:pages][page.num] = page.text.gsub(/<[^<]+?>/, "")
    end
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

protected

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

  def enqueue_process
    logger.info "Enqueue processing task for document with id #{id}"
    Resque.enqueue(DocumentProcessBootstrapTask, id)
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
    jobs = [Resque::Failure.all(opts[:offset], opts[:limit])].flatten.compact
  end
end
