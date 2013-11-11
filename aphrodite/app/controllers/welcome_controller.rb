class WelcomeController < ApplicationController
  def index
    @documents = Document.count
    @people = Person.count
    @organizations = NamedEntity.where(tag: 'NP00O00').count
    @places = NamedEntity.where(tag: 'NP00G00').count
    @dates = NamedEntity.where(tag: 'W').count
  end
end
