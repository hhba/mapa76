class EntitiesProvider
  attr_reader :user, :type

  def initialize(user, type = :people)
    @user = user
    @type = type
  end

  def for(list=[])
    documents = user.documents.find(list)
    documents.map(&type).flatten.sort_by { |entity| -1 * entity.mentions.values.inject(:+) }
  end
end