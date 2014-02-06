require 'ostruct'

class SearcherService
  include ActionView::Helpers::TextHelper

  attr_accessor :user, :q, :ids

  def initialize(user)
    @user = user
  end

  def where(str, document_id=nil)
    store(str)
    this = self
    documents_search = Tire.search(documents_index) do
      query do
        boolean do
          must { string str }
          must { term :user_id, this.user.id }
          must { term :document_id, document_id} if document_id
        end
      end
    end

    pages_search = Tire.search(pages_index) do
      query do
        boolean do
          must { string str }
          must { term :user_id, this.user.id}
          must { term :document_id, document_id} if document_id
        end
      end
      highlight :text
    end

    output = []

    pages_search.results.group_by(&:document_id).each do |document_id, pages|
      begin
        document = Document.find(document_id)
        highlights = {}
        pages.each { |page| highlights[page.num] = page.highlight}
        output << OpenStruct.new(title: document.title,
                                 document_id: document.id,
                                 original_filename: document.original_filename,
                                 created_at: document.created_at,
                                 counters: build_counters(document),
                                 highlight: highlights)
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end
    end

    documents_search.results.each do |doc_result|
      unless output.detect { |doc| doc.title == doc_result.title }
        output << doc_result
      end
    end

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
    "documents_#{Rails.env}"
  end

  def pages_index
    "pages_#{Rails.env}"
  end

  def entities_index
    "entities_#{Rails.env}"
  end
end
