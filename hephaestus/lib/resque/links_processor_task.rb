require 'httparty'


class LinksProcessorTask < Base
  @queue = :links_processor_task
  @msg = "Procesando enlaces"

  include HTTParty

  class ApiError < RuntimeError; end
  base_uri "access.alchemyapi.com/"

  def self.perform(document_id)
    self.new(document_id).call
  end

  def initialize(document_id)
    @document_id = document_id
  end

  def call
    TitleExtractor.new(@document_id).call
    LinkTextExtractor.new(@document_id).call
    LinkEntitiesExtractor.new(@document_id).call
    LinkNamedEntitiesExtractor.new(@document_id).call
    IndexerTask.perform(@document_id)
  end
end
