class SearcherService
  attr_accessor :query, :user

  def initialize(user, query)
    @user = user
    @query = query
  end

  def call
    @search = Document.tire.search do |s|
      s.fields :id
      s.filter :term, user_id: [user.id]
      s.query do |q|
        query.blank? ? q.all : q.string(query)
      end
      s.highlight :title, *(1..10000).map(&:to_s)
    end
    @search.results
  end
end
