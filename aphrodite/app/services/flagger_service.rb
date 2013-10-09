class FlaggerService
  attr_reader :document, :user

  def initialize(user, document)
    @user = user
    @document = document
  end

  def call
    document.flag!(user)
    FlagMailer.flag(user, document).deliver
  end
end
