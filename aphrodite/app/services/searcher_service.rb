class SearcherService
  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def call(q)
    this = self
    results = Document.tire.search do
      fields :id
      query do
        boolean do
          must { string q }
          must { term :user_id, this.user.id }
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
end
