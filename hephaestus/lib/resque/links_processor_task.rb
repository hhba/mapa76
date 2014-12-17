require 'httparty'


class LinksProcessorTask < BaseTask
  @queue = "links_processor_task"
  @msg = "Procesando enlace"

  include HTTParty

  class ApiError < RuntimeError; end
  base_uri "access.alchemyapi.com/"

  def initialize(input)
    @metadata = input['metadata']
    @document_id = input['metadata']['document_id']
  end

  def call
    TitleExtractor.new(@document_id).call
    LinkTextExtractor.new(@document_id).call
    LinkEntitiesExtractor.new(@document_id).call
    LinkNamedEntitiesExtractor.new(@document_id).call
    IndexerTask.new({'metadata' => { 'document_id' => @document_id}})

    @output = {
      'metadata' => metadata
    }
  end
end
