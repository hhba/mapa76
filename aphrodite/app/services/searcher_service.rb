class SearcherService
  attr_accessor :user, :q, :ids

  def initialize(user)
    @user = user
  end

  def where(opt={})
    @q = opt[:q]
    @ids = opt.fetch(:ids, [])
    store(@q) unless @q.nil?
    call
  end

  def call
    this = self
    results = Document.tire.search do
      query do
        boolean do
          must { string this.q }
          must { term :user_id, this.user.id }
          must { ids values: this.ids } unless this.ids.empty?
        end
      end
      highlight :title, *(1..10000).map(&:to_s)
      facet "users" do
        terms :user_id
      end
    end
    results.map do |item|
      [item, item.load]
    end
  end

  def search(str)
    output = []
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
    end
    
    # entities_search = Tire.search(entities_index) do
    #   query do
    #     boolean do
    #       must { string str }
    #       must { term :user_id, user_id}
    #     end
    #   end
    # end

    [documents_search, pages_search].each do |search|
      search.results.each do |result|
        output << result
      end
    end
    output.sort(&:_score)
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
