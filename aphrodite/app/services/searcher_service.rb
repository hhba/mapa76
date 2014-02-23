require 'ostruct'
require 'set'

class SearcherService
  include ActionView::Helpers::TextHelper

  attr_accessor :user, :q, :ids

  def initialize(user)
    @user = user
  end

  def where(str, document_id=nil)
    store(str)
    client = Rails.application.config.elasticsearch_client

    query = {
      bool: {
        must:[
          {
            query_string: { query: str }
          },
          {
            term: {
              user_id: { term: user.id}
            }
          }
        ]
      }
    }
    query[:bool][:must] << { term: {document_id: {term: document_id }}} if document_id

    puts query.inspect

    highlight = {
      fields: { text:{}}
    }

    response = client.search index: "#{documents_index},#{pages_index}", body: { from: 0, size: 50, query: query, highlight: highlight }
    process_response(response)
  end

  def process_response(response)
    output = []

    Document.find(get_document_ids(response)).each do |document|
      page_results = response.fetch('hits', {})['hits'].select do |result|
        result['_index'] == pages_index && result['_source']['document_id'] == document.id.to_s
      end
      output << if page_results.empty?
        build_document_result(document)
      else
        build_document_with_pages_result(document, page_results)
      end
    end
    output
  end

  def get_document_ids(response)
    output = Set.new
    response.fetch('hits', {})['hits'].each do |result|
      output.add(result['_source']['document_id'])
    end
    output.to_a
  end

  def build_document_result(document)
    {
      title: document.title,
      original_filename: document.original_filename,
      document_id: document.id,
      created_at: document.created_at,
      counters: build_counters(document)
    }
  end

  def build_document_with_pages_result(document, page_results)
    output = build_document_result(document)
    highlight = {}
    page_results.each do |result|
      highlight[result['_source']['num']] = result['highlight']
    end
    output['highlight'] = highlight
    output
  end

  def build_counters(document)
    {
      people: document.context_cache.fetch('people', []).count,
      organizations: document.context_cache.fetch('organizations', []).count,
      places: document.context_cache.fetch('places', []).count,
      dates: document.context_cache.fetch('dates', []).count
    }
  end

  def destroy_for(document)
    user_id = user.id
    document_id = document.id
    index = Tire::Index.new(documents_index)
    search = Tire.search(documents_index) do
      query do
        boolean do
          must { term :document_id, document_id}
        end
      end
    end.results.each { |result| index.remove result.id }

    index = Tire::Index.new(pages_index)
    Tire.search(pages_index) do
      query do
        boolean do
          must { term :document_id, document_id}
        end
      end
    end.results.each { |result| puts index.remove result.id }
  end

  def store(query)
    Search.create user: user, term: query
  end

  def documents_index
    Rails.application.config.elasticsearch_prefix + "_documents"
  end

  def pages_index
    Rails.application.config.elasticsearch_prefix + "_pages"
  end
end
