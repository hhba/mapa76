require 'tire'
require 'active_support/all'

class IndexerTask < BaseTask
  attr_accessor :pages, :document, :user_id
  @queue = "indexer_task"
  @msg = "Indexando documento"
  @next_task = nil

  def self.reset!
    create_index(force: true)
    Document.all.each { |d| self.perform(d.id) }
  end

  def self.create_index(opt={})
    force = opt.fetch(:force, false)
    if force || !Tire::Index.new(documents_index).exists?
      index = Tire.index documents_index do
        delete
        create
        mapping do
          indexes :title,             analyzer: "snowball", boost: 100
          indexes :original_filename, analyzer: "snowball", boost: 90
          indexes :document_id,       index: :not_analyzed
          indexes :user_id,           index: :not_analyzed
          indexes :created_at,        index: :not_analyzed
          indexes :counters,          index: :not_analyzed
        end
      end
    end

    if force || !Tire::Index.new(pages_index).exists?
      index = Tire.index pages_index do
        delete
        create
        mapping do
          indexes :text,        analyzer: "snowball", boost: 80
          indexes :num,         index: :not_analyzed
          indexes :user_id,     index: :not_analyzed
          indexes :document_id, index: :not_analyzed
          indexes :counters,    index: :not_analyzed
        end
      end
    end

    # if force || !Tire::Index.new(entities_index).exists?
    #   index = Tire.index entities_index do
    #     delete
    #     create
    #     mapping do
    #       indexes :name,        analyzer: 'snowball', boost: 70
    #       indexes :entity_type, index: :not_analyzed
    #       indexes :user_id,     index: :not_analyzed
    #       indexes :entity_id,   index: :not_analyzed
    #       indexes :type,        index: :not_analyzed
    #     end
    #   end
    #   logger.debug "[INDEX] #{index.name} | #{index.response}"
    # end
  end

  def self.documents_index
    Tire::Model::Search.index_prefix + "_documents"
  end

  def self.pages_index
    Tire::Model::Search.index_prefix + "_pages"
  end

  def self.entities_index
    Tire::Model::Search.index_prefix + "_entities"
  end

  def initialize(input)
    @metadata = input['metadata']
    @document = Document.find(input['metadata']['document_id'])
    @document = document
    @pages = document.pages
    @user_id = document.user_id
    self.class.create_index
  end

  def call
    pages = build_pages
    document_info = {
      title: document.title,
      original_filename: document.original_filename,
      user_id: user_id,
      document_id: document.id,
      created_at: document.created_at
    }
    entities = build_entities
    Tire.index self.class.documents_index do
      store document_info
      refresh
    end
    Tire.index self.class.pages_index do
      import pages
      refresh
    end

    @output = {
      'metadata' => metadata
    }
  end

  def build_pages
    pages.map do |page|
      {
        text: page.text,
        num: page.num,
        user_id: user_id,
        document_id: document.id,
      }
    end
  end

  def build_counters(document)
    {
      people: document.context_cache.fetch('people', []).count,
      organizations: document.context_cache.fetch('organizations', []).count,
      places: document.context_cache.fetch('places', []).count,
      dates: document.context_cache.fetch('dates', []).count
    }
  end

  def build_entities
    output =[]
    %w(organizations people date_entities places addresses).each do |entity_group|
      entity_type = entity_group.singularize
      output << document.send(entity_group.to_sym).map do |entity|
        { id: entity.id, name: entity.name, entity_type: entity_type }
      end
    end
    output.flatten
  end

  def search(cad)
    Tire.search documents_index do
      query do
        string cad
      end
    end
  end
end
