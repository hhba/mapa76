# encoding: utf-8

class NotificationMailer < ActionMailer::Base
  default from: "info@analice.me", to: 'info@analice.me'

  def flag(user, document)
    @user = user
    @document = document
    mail subject: "[Analice.me] Documento reportado"
  end

  def invitation_request(invitation)
    @invitation = invitation
    mail subject: '[Analice.me] Pedido de invitación'
  end
end
