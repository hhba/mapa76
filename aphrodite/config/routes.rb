Mapa76::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  resources :people do
    post "blacklist", :on => :member
  end

  resources :invitations, only: [:new, :create]

  resources :projects, :except => [:edit, :update, :delete] do
    member do
      get    'add_documents'
      post   'add_document'
      delete 'remove_document'
    end
  end

  resources :documents do
    get 'status', :on => :collection

    member do
      get  'context'
      get  'comb'
      get  'download'
      get  'export'
      post 'flag'
    end

    collection do
      get 'search'
      post 'link'
    end
  end

  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :documents
      resources :people, only: [:show]
      resources :named_entities, only: [:show]
      resources :projects, only: [:show, :index]
    end
    resources :documents, only: [:show, :destroy]
    resources :people
    resources :registers
  end

  get "/contact" => "welcome#contact"
  post "/save_contact" => "welcome#save_contact"
  root :to => "welcome#index"

  get "#{Mapa76::Application.config.thumbnails_path}/:id" => "documents#generate_thumbnail"
  get '/blog' => redirect('/blog/')
end
