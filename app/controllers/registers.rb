require 'json'

Alegato.controllers :registers, :provides => [:json] do
  get :index do
    FactRegister.timeline_json
  end
end
