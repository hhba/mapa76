class WelcomeController < ApplicationController
  def index
    @documents = Document.public.limit(5)
  end
end
