# RailsAdmin config file. Generated on October 11, 2013 17:12
# See github.com/sferik/rails_admin for more informations

RailsAdmin.config do |config|


  ################  Global configuration  ################

  # Set the admin name here (optional second array element will appear in red). For example:
  config.main_app_name = ['Analice.me', 'Admin']
  # or for a more dynamic name:
  # config.main_app_name = Proc.new { |controller| [Rails.application.engine_name.titleize, controller.params['action'].titleize] }

  # RailsAdmin may need a way to know who the current user is]
  config.current_user_method { current_user_admin } # auto-generated

  # If you want to track changes on your models:
  # config.audit_with :history, 'User'

  # Or with a PaperTrail: (you need to install it first)
  # config.audit_with :paper_trail, 'User'

  # Display empty fields in show views:
  # config.compact_show_view = false

  # Number of default rows per-page:
  # config.default_items_per_page = 20

  # Exclude specific models (keep the others):
  # config.excluded_models = ['Document', 'FactRegister', 'NamedEntity', 'Person', 'Search', 'User']

  # Include specific models (exclude the others):
  # config.included_models = ['Document', 'FactRegister', 'NamedEntity', 'Person', 'Search', 'User']

  # Label methods for model instances:
  # config.label_methods << :description # Default is [:name, :title]


  ################  Model configuration  ################

  # Each model configuration can alternatively:
  #   - stay here in a `config.model 'ModelName' do ... end` block
  #   - go in the model definition file in a `rails_admin do ... end` block

  # This is your choice to make:
  #   - This initializer is loaded once at startup (modifications will show up when restarting the application) but all RailsAdmin configuration would stay in one place.
  #   - Models are reloaded at each request in development mode (when modified), which may smooth your RailsAdmin development workflow.


  # Now you probably need to tour the wiki a bit: https://github.com/sferik/rails_admin/wiki
  # Anyway, here is how RailsAdmin saw your application's models when you ran the initializer:



  ###  Document  ###

  # config.model 'Document' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your document.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association 
  #     configure :people, :has_and_belongs_to_many_association 
  #     configure :project, :has_and_belongs_to_many_association         # Hidden 
  #     configure :pages, :has_many_association         # Hidden 
  #     configure :fact_registers, :has_many_association 
  #     configure :named_entities, :has_many_association 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :title, :string 
  #     configure :published_at, :date 
  #     configure :description, :text 
  #     configure :original_title, :text 
  #     configure :original_filename, :text 
  #     configure :context_cache, :serialized 
  #     configure :information, :serialized 
  #     configure :fontspecs, :serialized 
  #     configure :last_analysis_at, :datetime 
  #     configure :processed_text, :text 
  #     configure :status, :text 
  #     configure :tasks, :serialized 
  #     configure :public, :boolean 
  #     configure :percentage, :float 
  #     configure :flagger_id, :bson_object_id 
  #     configure :file_id, :bson_object_id 
  #     configure :thumbnail_file_id, :bson_object_id 
  #     configure :user_id, :bson_object_id         # Hidden 
  #     configure :person_ids, :serialized         # Hidden 
  #     configure :project_ids, :serialized         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  FactRegister  ###

  # config.model 'FactRegister' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your fact_register.rb model definition

  #   # Found associations:

  #     configure :fact, :belongs_to_association         # Hidden 
  #     configure :document, :belongs_to_association 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :person_ids, :serialized 
  #     configure :place_id, :bson_object_id 
  #     configure :date_id, :bson_object_id 
  #     configure :action_ids, :serialized 
  #     configure :passive, :boolean 
  #     configure :complement_person_ids, :serialized 
  #     configure :fact_id, :bson_object_id         # Hidden 
  #     configure :document_id, :bson_object_id         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  NamedEntity  ###

  # config.model 'NamedEntity' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your named_entity.rb model definition

  #   # Found associations:

  #     configure :document, :belongs_to_association 
  #     configure :pages, :has_and_belongs_to_many_association         # Hidden 
  #     configure :person, :belongs_to_association 
  #     configure :blacklist, :belongs_to_association         # Hidden 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :text, :text 
  #     configure :pos, :integer 
  #     configure :inner_pos, :serialized 
  #     configure :document_id, :bson_object_id         # Hidden 
  #     configure :page_ids, :serialized         # Hidden 
  #     configure :ne_class, :string 
  #     configure :form, :text 
  #     configure :lemma, :text 
  #     configure :tag, :text 
  #     configure :prob, :float 
  #     configure :tokens, :serialized 
  #     configure :person_id, :bson_object_id         # Hidden 
  #     configure :blacklist_id, :bson_object_id         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Person  ###

  # config.model 'Person' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your person.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association 
  #     configure :documents, :has_and_belongs_to_many_association 
  #     configure :named_entities, :has_many_association 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :created_at, :datetime 
  #     configure :updated_at, :datetime 
  #     configure :name, :string 
  #     configure :surname_father, :text 
  #     configure :searchable_name, :text 
  #     configure :jurisdiction, :text 
  #     configure :force, :text 
  #     configure :mentions, :serialized 
  #     configure :tags, :serialized 
  #     configure :confidence, :float 
  #     configure :user_id, :bson_object_id         # Hidden 
  #     configure :document_ids, :serialized         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  Search  ###

  # config.model 'Search' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your search.rb model definition

  #   # Found associations:

  #     configure :user, :belongs_to_association 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :term, :text 
  #     configure :user_id, :bson_object_id         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end


  ###  User  ###

  # config.model 'User' do

  #   # You can copy this to a 'rails_admin do ... end' block inside your user.rb model definition

  #   # Found associations:

  #     configure :projects, :has_and_belongs_to_many_association         # Hidden 
  #     configure :documents, :has_many_association 
  #     configure :people, :has_many_association 

  #   # Found columns:

  #     configure :_type, :text         # Hidden 
  #     configure :_id, :bson_object_id 
  #     configure :email, :text 
  #     configure :password, :password         # Hidden 
  #     configure :password_confirmation, :password         # Hidden 
  #     configure :reset_password_token, :text         # Hidden 
  #     configure :reset_password_sent_at, :datetime 
  #     configure :remember_created_at, :datetime 
  #     configure :sign_in_count, :integer 
  #     configure :current_sign_in_at, :datetime 
  #     configure :last_sign_in_at, :datetime 
  #     configure :current_sign_in_ip, :text 
  #     configure :last_sign_in_ip, :text 
  #     configure :confirmation_token, :text 
  #     configure :confirmed_at, :datetime 
  #     configure :confirmation_sent_at, :datetime 
  #     configure :project_ids, :serialized         # Hidden 

  #   # Cross-section configuration:

  #     # object_label_method :name     # Name of the method called for pretty printing an *instance* of ModelName
  #     # label 'My model'              # Name of ModelName (smartly defaults to ActiveRecord's I18n API)
  #     # label_plural 'My models'      # Same, plural
  #     # weight 0                      # Navigation priority. Bigger is higher.
  #     # parent OtherModel             # Set parent model for navigation. MyModel will be nested below. OtherModel will be on first position of the dropdown
  #     # navigation_label              # Sets dropdown entry's name in navigation. Only for parents!

  #   # Section specific configuration:

  #     list do
  #       # filters [:id, :name]  # Array of field names which filters should be shown by default in the table header
  #       # items_per_page 100    # Override default_items_per_page
  #       # sort_by :id           # Sort column (default is primary key)
  #       # sort_reverse true     # Sort direction (default is true for primary key, last created first)
  #     end
  #     show do; end
  #     edit do; end
  #     export do; end
  #     # also see the create, update, modal and nested sections, which override edit in specific cases (resp. when creating, updating, modifying from another model in a popup modal or modifying from another model nested form)
  #     # you can override a cross-section field configuration in any section with the same syntax `configure :field_name do ... end`
  #     # using `field` instead of `configure` will exclude all other fields and force the ordering
  # end

end
