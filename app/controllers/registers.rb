require 'json'

Alegato.controllers :registers, :provides => [:json] do
  get :index do
    Register.timeline_json
  end
end
