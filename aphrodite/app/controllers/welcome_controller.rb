class WelcomeController < ApplicationController
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
    if @contact.save
      redirect_to root_path, notice: 'Se ha notificado a nuestros administradores'
    else
      render :contact
    end
  end
end
