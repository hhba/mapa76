require 'ostruct'

class SearcherService
  include ActionView::Helpers::TextHelper

  attr_accessor :user, :q, :ids

  def initialize(user)
    @user = user
  end

  def where(str)
    store(str)
    user_id = user.id
    documents_search = Tire.search(documents_index) do
      query do
        boolean do
          must { string str }
          must { term :user_id, user_id}
        end
      end
    end

    pages_search = Tire.search(pages_index) do
      query do
        boolean do
          must { string str }
          must { term :user_id, user_id}
        end
      end
      highlight :text
    end

    output = []
    documents_search.results.each do |result|
      output << result
    end

    pages_search.results.group_by(&:document_id).each do |document_id, pages|
      begin
        document = Document.find(document_id)
        highlights = {}
        pages.each { |page| highlights[page.num] = page.highlight}
        output << OpenStruct.new(title: document.title,
                                 document_id: document.id,
                                 original_filename: document.original_filename,
                                 created_at: document.created_at,
                                 highlight: highlights)
      rescue Mongoid::Errors::DocumentNotFound
        nil
      end
    end

    output
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
