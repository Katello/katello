
Src::Application.routes.draw do

  apipie

  resources :system_groups do
    collection do
      get :items
      get :auto_complete
      get :validate_name
    end
    member do
      post :copy
      get :systems
      post :add_systems
      post :remove_systems
      delete :destroy_systems
      get :edit_systems
      put :update_systems
    end
    resources :events, :controller => "system_group_events", :only => [:index, :show] do
      collection do
        get :status, action: :event_status
        get :more_items
        get :items
      end
    end
    resources :packages, :controller => "system_group_packages", :only => [:index] do
      collection do
        put :add
        put :remove
        put :update
        get :status, action: :package_status
      end
    end
    resources :errata, :controller => "system_group_errata", :only => [:index] do
      collection do
        get :items
        post :install
        get :status, action: :errata_status
      end
    end
  end

  resources :content_search do
      collection do
        post :errata
        post :products
        post :packages
        post :packages_items
        post :errata_items
        get :view_packages
        post :repos
        post :views
        get :repo_packages
        get :repo_errata
        get :repo_compare_packages
        get :repo_compare_errata
        get :view_compare_packages
        get :view_compare_errata
      end
  end

  resources :content_view_definitions do
    collection do
      get :default_label
      get :items
    end

    member do
      post :clone
      get :views
      get :publish_setup
      post :publish
      get :status, action: :definition_status
      get :content
      put :update_content
      put :update_component_views
    end

    resources :content_views, :only => [:destroy] do
      member do
        post :refresh
      end
    end

    resources :filters, :controller => :filters, :only => [:index, :new, :create, :edit, :update] do
      collection do
        delete :destroy_filters
      end

      resources :rules, :controller => :filter_rules, :only => [:new, :create, :edit, :update] do
        collection do
          delete :destroy_rules
        end

        member do
          get :edit_inclusion
          get :edit_parameter_list
          get :edit_date_type_parameters
          put :add_parameter
          put :update_parameter
          delete :destroy_parameters
        end
      end
    end
  end

  resources :content_views do
    collection do
       get :auto_complete
    end
  end

  resources :activation_keys do
    collection do
      get :auto_complete_search
      get :items
      get :subscriptions
    end
    member do
      get :applied_subscriptions
      get :available_subscriptions
      post :remove_subscriptions
      post :add_subscriptions

      post :update

      get :system_groups
      get :systems
      put :add_system_groups
      put :remove_system_groups
    end
  end

  resources :gpg_keys do
    collection do
      get :auto_complete_search
      get :items
    end
    member do
      get :products_repos
      post :update
    end
  end

  resources :sync_plans, :only => [:index, :create, :new, :edit, :update, :show, :destroy, :auto_complete_search] do
    collection do
      get :auto_complete_search
      get :items
    end
  end

  get  "sync_schedules/index"
  post "sync_schedules/apply"

  get "sync_management/manage"
  get "sync_management/index"
  post "sync_management/sync"
  get  "sync_management/sync_status"
  get  "sync_management/product_status"
  resources :sync_management, :only => [:destroy]

  get "notices/note_count"
  get "notices/get_new"
  get "notices/auto_complete_search"
  match 'notices/:id/details' => 'notices#details', :via => :get, :as => 'notices_details'
  match 'notices' => 'notices#show', :via => :get
  match 'notices' => 'notices#destroy_all', :via => :delete

  resources :subscriptions do
    member do
      get :edit
      get :products
      get :consumers
    end
    collection do
      get :items
      post :upload
      post :delete_manifest
      post :refresh_manifest
      get :history
      get :history_items
      get :edit_manifest
    end
  end

  resources :dashboard, :only => [:index] do
    collection do
      get :sync
      get :notices
      get :errata
      get :content_views
      get :promotions
      get :systems
      get :system_groups
      get :subscriptions
      put :update
    end
  end

  resources :systems do
    resources :events, :only => [:index, :show], :controller => "system_events" do
      collection do
        get :status, action: :event_status
        get :more_events
        get :items
      end
    end
    resources :system_packages, :only => {} do
      collection do
        put :add
        post :remove
        post :update
        get :packages
        get :more_packages
        get :status, action: :package_status
      end
    end
    resources :errata, :controller => "system_errata", :only => [:index, :update] do
      collection do
        get :items
        post :install
        get :status, action: :errata_status
      end
    end

    member do
      get :edit
      get :subscriptions
      post :update_subscriptions
      get :products
      get :more_products
      get :facts
      get :system_groups
      put :add_system_groups
      put :remove_system_groups
      get :custom_info
    end
    collection do
      get :auto_complete
      get :items
      get :env_items
      get :environments
      delete :bulk_destroy
      post :bulk_add_system_group
      post :bulk_remove_system_group
      post :bulk_content_install
      post :bulk_content_update
      post :bulk_content_remove
      post :bulk_errata_install
    end
  end
  resources :operations, :only => [:index]  do
  end

  resources :packages, :only => [:show] do
    member do
      get :changelog
      get :filelist
      get :dependencies
      get :details
    end
    collection do
      get :auto_complete_library
      get :auto_complete_nvrea_library
      get :validate_name_library
      get :auto_complete
    end
  end

  resources :errata, :only => [:show] do
    collection do
      get :auto_complete
    end
    member do
      get :packages
      get :short_details
    end
  end

  resources :distributors do
    resources :events, :only => [:index, :show], :controller => "distributor_events" do
      collection do
        get :status, action: :distributor_status
        get :more_events
        get :items
      end
    end

    member do
      get :edit
      get :subscriptions
      post :update_subscriptions
      get :products
      get :more_products
      get :download
      get :custom_info
    end
    collection do
      get :auto_complete
      get :items
      get :env_items
      get :environments
      delete :bulk_destroy
    end
  end

  resources :products, :only => [:new, :create, :edit,:update, :destroy] do
    collection do
      get :auto_complete
    end
    member do
      put :refresh_content
      put :disable_content
    end
  end

  resources :users do
    collection do
      get :auto_complete_search
      get :items
      post :enable_helptip
      post :disable_helptip
    end
    member do
      post :clear_helptips
      put :update_roles
      put :update_locale
      put :update_preference
      put :setup_default_org
      get :edit_environment
      put :update_environment
    end
  end

  resources :providers do
    collection do
      get :auto_complete_search
      put :refresh_products
    end

    resources :products do
      get :default_label, :on => :collection

      resources :repositories, :only => [:new, :create, :edit, :destroy] do
        get :default_label, :on => :collection
        member do
          put :update_gpg_key, :as => :update_repo_gpg_key
        end
      end
    end
    collection do
      get :items
      get :redhat_provider
      post :redhat_provider, :action => :update_redhat_provider
    end
    member do
      get :repo_discovery
      get :discovered_repos
      get :new_discovered_repos
      post :discover
      post :cancel_discovery
      get :products_repos
      get :manifest_progress
      get :schedule
    end
  end

  match '/providers/:id' => 'providers#update', :via => :put
  match '/providers/:id' => 'providers#update', :via => :post

  match '/repositories/:id/enable_repo' => 'repositories#enable_repo', :via => :put, :as => :enable_repo

  resources :repositories, :only => [:new, :create, :edit, :destroy] do
    collection do
      get :auto_complete_library
    end

    resources :distributions, :only => [:show], :constraints => { :id => /[0-9a-zA-Z \-\+%_.]+/ } do
      member do
        get :filelist
      end
    end
  end

  resources :promotions, :only =>[] do
    collection do
      get :index, :action =>:show
    end
    member do
      get :show
      get :products
      get :packages
      get :errata
      get :repos
      get :distributions
      get :details
      get :content_views
    end

  end

  match '/organizations/:org_id/environments/:env_id/edit' => 'environments#update', :via => :put

  resources :organizations do
    collection do
      get :auto_complete_search
      get :items
      get :default_label
    end
    member do
      get :show
      get :environments_partial
      get :events
      get :download_debug_certificate
      get :apply_default_info_status
    end
    resources :environments do
      get :default_label, :on => :collection
      member do
        get :products
        get :content_views
      end
      resources :content_view_versions, :only => [:show] do
        member do
          get :content
        end
      end
    end
  end
  match '/organizations/:id/edit' => 'organizations#update', :via => :put
  match '/organizations/:id/default_info/:informable_type' => 'organizations#default_info', :via => :get, :as => :organization_default_info

  resources :changesets, :only => [:update, :index, :show, :create, :new, :edit, :destroy] do
    member do
      put :name
      get :dependencies
      post :apply
      get :status, action: :changeset_status
      get :object
    end
    collection do
      get :auto_complete_search
      get :list
      get :items
    end
  end

  resources :environments do
    member do
      get :content_views
    end
  end

  match '/roles/show_permission' => 'roles#show_permission', :via=>:get
  resources :roles do
    put "create_permission" => "roles#create_permission"

    resources :permission, :only => {} do
      delete "destroy_permission" => "roles#destroy_permission", :as => "destroy"
      post "update_permission" => "roles#update_permission", :as => "update"
    end
    collection do
      get :auto_complete_search
      get :items
    end
    resources :ldap_groups, :only => [] do
      member do
        delete "destroy" => "roles#destroy_ldap_group", :as => "destroy"
      end
      collection do
        post "create" => "roles#create_ldap_group", :as => "create"
      end
    end
  end
  match '/roles/:organization_id/resource_type/verbs_and_scopes' => 'roles#verbs_and_scopes', :via=>:get, :as=>'verbs_and_scopes'

  resources :search, :only => {} do
    get 'show', :on => :collection

    get 'history', :on => :collection
    delete 'history' => 'search#destroy_history', :on => :collection

    get 'favorite', :on => :collection
    post 'favorite' => 'search#create_favorite', :on => :collection
    delete 'favorite/:id' => 'search#destroy_favorite', :on => :collection, :as => 'destroy_favorite'
  end

  resource :user_session do
    post 'set_org'
    get 'allowed_orgs'
  end


  root :to => "user_sessions#new"

  match '/login' => 'user_sessions#new', :as => 'login'
  match '/logout' => 'user_sessions#destroy', :via => [:post, :get]
  match '/user_session/logout' => 'user_sessions#destroy'
  match '/user_session' => 'user_sessions#show', :via => :get, :as => 'show_user_session'
  match '/authenticate' => 'user_sessions#authenticate', :via => :get

  resources :password_resets, :only => [:create, :edit, :update] do
    collection do
      post :email_logins
    end
  end

  match 'about', :to => "application_info#about", :as => "about"

end
