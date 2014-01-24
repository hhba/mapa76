require 'tire'
require 'active_support/all'

class IndexerTask < Base
  attr_accessor :pages, :document, :user_id
  @queue = :idexer_task
  @msg = "Indexando documento"

  def self.perform(document_id)
    self.new(document_id).call
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
        end
      end
      logger.debug "[INDEX] #{index.name} | #{index.response}"
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
        end
      end
      logger.debug "[INDEX] #{index.name} | #{index.response}"
    end

    if force || !Tire::Index.new(entities_index).exists?
      index = Tire.index entities_index do
        delete
        create
        mapping do
          indexes :name,        analyzer: 'snowball', boost: 70
          indexes :entity_type, index: :not_analyzed
          indexes :user_id,     index: :not_analyzed
          indexes :entity_id,   index: :not_analyzed
          indexes :type,        index: :not_analyzed
        end
      end
      logger.debug "[INDEX] #{index.name} | #{index.response}"
    end
  end

  def self.documents_index
    "documents_#{APP_ENV}"
  end

  def self.pages_index
    "pages_#{APP_ENV}"
  end

  def self.entities_index
    "entities_#{APP_ENV}"
  end

  def initialize(document_id)
    @document = Document.find(document_id)
    @document = document
    @pages = document.pages
    @user_id = document.user_id
    self.class.create_index
  end

  def call
    pages = build_pages
    document_info = {title: document.title, original_title: document.original_title, user_id: user_id, document_id: document.id}
    entities = build_entities
    Tire.index self.class.documents_index do
      store document_info
      refresh
    end
    Tire.index self.class.pages_index do
      import pages
      refresh
    end
    Tire.index self.class.entities_index do
      import entities
      refresh
    end
  end

  def build_pages
    pages.map do |page|
      { text: page.text, num: page.num, user_id: user_id, document_id: document.id }
    end
  end

  def build_entities
    output =[]
    %w(organizations people date_entities places addresses).each do |entity_group|
      entity_type = entity_group.singularize
      output << document.send(entity_group.to_sym).map { |entity| {id: entity.id, name: entity.name, entity_type: entity_type} }
    end
    puts output.flatten
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
