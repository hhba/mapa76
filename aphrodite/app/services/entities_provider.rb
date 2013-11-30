class EntitiesProvider
  attr_reader :user, :type

  def initialize(user, type = :people)
    @user = user
    @type = type
  end

  def for(list=[])
    documents = user.documents.find(list)
    documents.map(&type).flatten
  end
end