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

  def store(query)
    Search.create user: user, term: query
  end
end
