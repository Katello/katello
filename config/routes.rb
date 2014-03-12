Katello::Engine.routes.draw do

  resources :system_groups do
    collection do
      get :items
      get :all
    end
  end

  resources :content_search do
    collection do
      post :errata
      post :products
      post :packages
      post :puppet_modules
      post :packages_items
      post :errata_items
      post :puppet_modules_items
      get :view_packages
      get :view_puppet_modules
      post :repos
      post :views
      get :repo_packages
      get :repo_errata
      get :repo_puppet_modules
      get :repo_compare_packages
      get :repo_compare_errata
      get :repo_compare_puppet_modules
      get :view_compare_packages
      get :view_compare_errata
      get :view_compare_puppet_modules
    end
  end

  resources :content_views, :only => [:index] do
    collection do
      get :all
    end
  end

  resources :activation_keys, :only => [:index] do
    collection do
      get :all
    end
  end

  resources :gpg_keys, :only => [:index] do
    collection do
      get :all
    end
  end

  resources :sync_plans, :only => [:index] do
    collection do
      get :all
    end
  end

  resources :sync_management, :only => [:destroy] do
    collection do
      get :manage
      get :index
      get :sync_status
      get :product_status
      post :sync
    end
  end

  get "notices/note_count"
  get "notices/get_new"
  get "notices/auto_complete_search"
  match 'notices/:id/details' => 'notices#details', :via => :get, :as => 'notices_details'
  match 'notices' => 'notices#show', :via => :get
  match 'notices' => 'notices#destroy_all', :via => :delete

  resources :subscriptions, :only => [:index] do
    collection do
      get :all
      get :index
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
      get :subscriptions_totals
      put :update
    end
  end

  resources :systems, :only => [:index] do
    collection do
      get :all
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

  resources :puppet_modules, :only => [:show] do
    collection do
      get :auto_complete
      get :author_auto_complete
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

  resources :products, :only => [:index] do
    member do
      put :refresh_content
      put :disable_content
    end
    collection do
      get :auto_complete
      get :all
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
      get :redhat_provider_tab
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
  end

  resources :promotions, :only => [] do
    collection do
      get :index, :action => :show
    end
    member do
      get :show
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
      collection do
        get :registerable_paths
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

  resources :environments do
    collection do
      get :all
    end
    member do
      get :content_views
    end
  end

  match '/roles/show_permission' => 'roles#show_permission', :via => :get
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
  match '/roles/:organization_id/resource_type/verbs_and_scopes' => 'roles#verbs_and_scopes', :via => :get, :as => 'verbs_and_scopes'

  resources :search, :only => {} do
    get 'show', :on => :collection

    get 'history', :on => :collection
    delete 'history' => 'search#destroy_history', :on => :collection

    get 'favorite', :on => :collection
    post 'favorite' => 'search#create_favorite', :on => :collection
    delete 'favorite/:id' => 'search#destroy_favorite', :on => :collection, :as => 'destroy_favorite'
  end

  root :to => "dashboard#index"

  match '/user_session/set_org' => 'user_sessions#set_org', :via => :post

  match 'about', :to => "application_info#about", :as => "about"
end
