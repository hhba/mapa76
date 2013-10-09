class FlagMailer < ActionMailer::Base
  default from: "info@analice.me", to: 'info@analice.me'

  def flag(user, document)
    @user = user
    @document = document
    mail subject: "[Analice.me] Documento reportado"
  end
end
