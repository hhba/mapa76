class WelcomeController < ApplicationController
  before_filter :redirect_to_docs, only: :index

  def index
    @documents = Document.count
    @people = Person.count
    @organizations = NamedEntity.where(tag: 'NP00O00').count
    @places = NamedEntity.where(tag: 'NP00G00').count
    @dates = NamedEntity.where(tag: 'W').count
  end

  def contact
    @contact = Contact.new
  end

  def save_contact
    @contact = Contact.new params[:contact]
    if @contact.valid? && @contact.save
      NotificationMailer.contact(@contact).deliver
      redirect_to root_path, notice: 'Gracias por contactarse con Analice.me. Nos comunicaremos a la brevedad.'
    else
      render :contact, error: "Se ha producido un error"
    end
  end

  def about
  end

  def terms
  end

  def faq
  end

private

  def redirect_to_docs
    if current_user
      redirect_to documents_path
      false
    end
  end
end
