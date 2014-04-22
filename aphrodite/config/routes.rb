Mapa76::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  devise_for :users

  resources :invitations, only: [:new, :create]

  resources :users, only: [:show, :edit, :update]
  resources :projects, :except => [:edit, :update, :delete] do
    member do
      get    'comb'
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
      post 'flag'
    end

    collection do
      get  'search'
      get  'export'
      get  'list'
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
    namespace :v2 do
      resources :people
      resources :organizations
      resources :places
      resources :date_entities
      resources :documents do
        resources :people
        resources :organizations
        resources :places
        resources :date_entities
        member do
          post :flag
          get  :pages
          get  :search
        end

        collection do
          get :status
          get :search
        end
      end
      delete 'documents' => 'documents#destroy'
    end
    resources :documents, only: [:show, :destroy]
    resources :people
    resources :registers
  end

  get "/about" => "welcome#about"
  get "/contact" => "welcome#contact"
  get "/terms" => "welcome#terms"
  get "/faq" => "welcome#faq"
  post "/save_contact" => "welcome#save_contact"
  root :to => "welcome#index"

  match '/api/v2/*route', to: 'api/v2/base#options', constraints: { method: 'OPTIONS' }

  get "#{Mapa76::Application.config.thumbnails_path}/:id" => "documents#generate_thumbnail"
  get '/blog' => redirect('/blog/')

  match '*not_found_page', :to => 'application#not_found_page'
end
