# encoding: utf-8

class NotificationMailer < ActionMailer::Base
  default from: "info@analice.me", to: Figaro.env.notification_email

  def flag(user, document)
    @user = user
    @document = document
    mail subject: "[Analice.me] Documento reportado"
  end

  def invitation_request(invitation)
    @invitation = invitation
    mail subject: '[Analice.me] Pedido de invitación'
  end

  def contact(contact)
    @contact = contact
    mail subject: '[Analice.me] Contacto'
  end
end
