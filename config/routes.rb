Src::Application.routes.draw do

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
      post :lock
    end
    resources :events, :controller => "system_group_events", :only => [:index, :show] do
      collection do
        get :status
        get :more_items
        get :items
      end
    end
    resources :packages, :controller => "system_group_packages", :only => [:index] do
      collection do
        put :add
        put :remove
        put :update
        get :status
      end
    end
    resources :errata, :controller => "system_group_errata", :only => [:index] do
      collection do
        get :items
        post :install
        get :status
      end
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

  resources :subscriptions, :only => [:index]

  resources :dashboard, :only => [:index] do
    collection do
      get :sync
      get :notices
      get :errata
      get :promotions
      get :systems
      get :subscriptions
    end
  end

  resources :systems do
    resources :events, :only => [:index, :show], :controller => "system_events" do
      collection do
        get :status
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
        get :status
      end
    end
    resources :errata, :controller => "system_errata", :only => [:index, :update] do
      collection do
        get :items
        post :install
        get :status
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
    end
    collection do
      get :auto_complete_library
      get :validate_name_library
    end
  end

  resources :errata, :only => [:show] do
    member do
      get :packages
    end
  end

  resources :products, :only => [:new, :create, :edit,:update, :destroy]

  resources :owners do
    member do
      post :import
      get :import_status
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
      get :edit_environment
      put :update_environment
    end
  end

  resources :filters do
    collection do
      get :auto_complete_search
      get :auto_complete_products_repos
      get :items
    end
    member do
      get  :packages
      post :add_packages
      post :remove_packages
      get  :products
      post :update_products
    end

  end

  resources :system_templates do
    collection do
      get :auto_complete_search
      get :items
      get :product_packages
      get :product_comps
      get :product_repos
    end
    member do
      get :promotion_details
      get :object
      get :download
      get :validate
      put :update_content
    end
  end

  resources :providers do
    get 'auto_complete_search', :on => :collection
    resources :products do
      resources :repositories, :only => [:new, :create, :edit, :destroy] do
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
      get :products_repos
#      get :subscriptions
#     post :subscriptions, :action=>:update_subscriptions
      get :schedule
    end
  end
  match '/providers/:id' => 'providers#update', :via => :put
  match '/providers/:id' => 'providers#update', :via => :post

  match '/repositories/:id/enable_repo' => 'repositories#enable_repo', :via => :put, :as => :enable_repo

  resources :repositories, :only => [:new, :create, :edit, :destroy] do
    get :auto_complete_library, :on => :collection

    resources :distributions, :only => [:show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.]+/ } do
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
      get :system_templates
      get :repos
      get :distributions
      get :details
    end

  end

  match '/organizations/:org_id/environments/:env_id/edit' => 'environments#update', :via => :put

  resources :organizations do
    collection do
      get :auto_complete_search
      get :items
    end
    member do
      get :environments_partial
      get :events
      get :download_debug_certificate
    end
    resources :environments do
      member do
        get :system_templates
        get :products
      end
    end
  end
  match '/organizations/:id/edit' => 'organizations#update', :via => :put

  resources :changesets, :only => [:update, :index, :show, :create, :new, :edit, :show, :destroy, :auto_complete_search] do
    member do
      put :name
      get :dependencies
      post :promote
      get :object
      get :promotion_progress
    end
    collection do
      get :auto_complete_search
      get :list
      get :items
    end
  end

  resources :environments

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

  match '/login' => 'user_sessions#new'
  match '/logout' => 'user_sessions#destroy', :via=>:post
  match '/user_session/logout' => 'user_sessions#destroy'
  match '/user_session' => 'user_sessions#show', :via=>:get, :as=>'show_user_session'

  resources :password_resets, :only => [:create, :edit, :update] do
    collection do
      get :email_logins
    end
  end

  namespace :api do
    class RegisterWithActivationKeyContraint
      def matches?(request)
        request.params[:activation_keys]
      end
    end
    match '/' => 'root#resource_list'

    # Headpin does not support system creation
    if AppConfig.katello?
      onlies = [:show, :destroy, :create, :index, :update]
    else
      onlies = [:show, :destroy, :index, :update]
    end
    resources :systems, :only => onlies do
      member do
        get :packages, :action => :package_profile
        get :errata
        get :pools
        get :releases
        put :enabled_repos
        post :system_groups, :action => :add_system_groups
        delete :system_groups, :action => :remove_system_groups
      end
      collection do
        match "/tasks/:id" => "systems#task_show", :via => :get
      end
      resources :subscriptions, :only => [:create, :index, :destroy] do
        collection do
            match '/' => 'subscriptions#destroy_all', :via => :delete
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
        end
      end
      resource :packages, :action => [:create, :update, :destroy], :controller => :system_packages
    end

    resources :providers, :except => [:index] do
      resources :sync, :only => [:index, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
      member do
        post :import_products
        post :import_manifest
        post :refresh_products
        post :product_create
        get :products
      end
    end

    resources :templates, :except => [:index] do
      post :import, :on => :collection
      get :export, :on => :member
      get :validate, :on => :member
      resources :products, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_product
        delete :destroy, :on => :member, :action => :remove_product
      end
      resources :packages, :controller => :templates_content, :constraints => { :id => /[0-9a-zA-Z\-_.]+/ } do
        post   :index, :on => :collection, :action => :add_package
        delete :destroy, :on => :member, :action => :remove_package
      end
      resources :parameters, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_parameter
        delete :destroy, :on => :member, :action => :remove_parameter
      end
      resources :package_groups, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_package_group
        delete :destroy, :on => :member, :action => :remove_package_group
      end
      resources :package_group_categories, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_package_group_category
        delete :destroy, :on => :member, :action => :remove_package_group_category
      end
      resources :distributions, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_distribution
        delete :destroy, :on => :member, :action => :remove_distribution
      end
      resources :repositories, :controller => :templates_content do
        post   :index, :on => :collection, :action => :add_repo
        delete :destroy, :on => :member, :action => :remove_repo
      end
    end

    resources :organizations do
      resources :products, :only => [:index, :show, :update, :destroy] do
        get :repositories, :on => :member
        post :sync_plan, :on => :member, :action => :set_sync_plan
        delete :sync_plan, :on => :member, :action => :remove_sync_plan
        get :repositories, :on => :member
        resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        resources :filters, :only => [] do
          get :index, :on => :collection, :action => :list_product_filters
          put :index, :on => :collection, :action => :update_product_filters
        end
      end

      resources :system_groups, :except => [:new, :edit] do
        member do
          get :systems
          get :history
          match "/history/:job_id" => "system_groups#history_show", :via => :get
          post :lock
          post :unlock
          post :add_systems
          post :remove_systems
          delete :destroy_systems
        end

        resource :packages, :action => [:create, :update, :destroy], :controller => :system_group_packages
        resources :errata, :only => [:index, :create], :controller => :system_group_errata
      end

      resources :environments do
        get :repositories, :on => :member
        resources :changesets, :only => [:index, :create]
      end
      resources :sync_plans
      resources :tasks, :only => [:index]
      resources :providers, :only => [:index]
      resources :systems, :only => [:index] do
        get :report, :on => :collection

        collection do
          get :tasks
        end
      end
      match '/systems' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
      resources :activation_keys, :only => [:index] do
        member do
          post :system_groups, :action => :add_system_groups
          delete :system_groups, :action => :remove_system_groups
        end
      end
      resources :repositories, :only => [] do
        post :discovery, :on => :collection
      end
      resource :uebercert, :only => [:show]
      resources :filters, :only => [:index, :create, :destroy, :show, :update]

      resources :gpg_keys, :only => [:index, :create]
    end

    resources :changesets, :only => [:show, :update, :destroy] do
      post :promote, :on => :member, :action => :promote
      get :dependencies, :on => :member, :action => :dependencies
      resources :products, :controller => :changesets_content do
        post   :index, :on => :collection, :action => :add_product
        delete :destroy, :on => :member, :action => :remove_product
      end
      resources :packages, :controller => :changesets_content, :constraints => { :id => /[0-9a-zA-Z\-_.]+/ } do
        post   :index, :on => :collection, :action => :add_package
        delete :destroy, :on => :member, :action => :remove_package
      end
      resources :errata, :controller => :changesets_content do
        post   :index, :on => :collection, :action => :add_erratum
        delete :destroy, :on => :member, :action => :remove_erratum
      end
      resources :repositories , :controller => :changesets_content do
        post   :index, :on => :collection, :action => :add_repo
        delete :destroy, :on => :member, :action => :remove_repo
      end
      resources :distributions, :controller => :changesets_content do
        post   :index, :on => :collection, :action => :add_distribution
        delete :destroy, :on => :member, :action => :remove_distribution
      end
      resources :templates, :controller => :changesets_content do
        post   :index, :on => :collection, :action => :add_template
        delete :destroy, :on => :member, :action => :remove_template
      end

    end

    #resources :puppetclasses, :only => [:index]
    resources :ping, :only => [:index]

    resources :repositories, :only => [:show, :create, :update, :destroy], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
      resources :sync, :only => [:index, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
      resources :packages do
        get :search, :on => :collection
      end
      resources :errata, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.:]+/ }
      resources :distributions, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.]+/ }
      resources :filters, :only => [] do
        get :index, :on => :collection, :action => :list_repository_filters
        put :index, :on => :collection, :action => :update_repository_filters
      end
      member do
        get :package_groups
        get :package_group_categories
        get :gpg_key_content
        post :enable
      end
      collection do
        post :sync_complete
      end
    end

    resources :environments, :only => [:show, :update, :destroy] do
      match '/systems' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
      resources :systems, :only => [:create, :index] do
        get :report, :on => :collection
      end
      resources :products, :only => [:index] do
        get :repositories, :on => :member
      end
      resources :activation_keys, :only => [:index, :create]
      resources :templates, :only => [:index]

      member do
        get :releases
      end
    end

    resources :gpg_keys, :only => [:show, :update, :destroy] do
      get :content, :on => :member
    end

    resources :activation_keys do
      post :pools, :action => :add_pool, :on => :member
      delete "pools/:poolid", :action => :remove_pool, :on => :member
    end

    resources :errata, :only => [:index]

    resources :users do
      get :report, :on => :collection
      get :sync_ldap_roles, :on => :collection
      resources :roles, :controller => :users do
       post   :index, :on => :collection, :action => :add_role
       delete :destroy, :on => :member, :action => :remove_role
       get    :index, :on => :collection, :action => :list_roles
      end
    end
    resources :roles do
      get :available_verbs, :on => :collection, :action => :available_verbs
      resources :permissions, :only => [:index, :show, :create, :destroy]
      resources :ldap_groups, :controller => :role_ldap_groups , :only => [:create, :destroy, :index]
    end

    resources :tasks, :only => [:show]

    resources :crls, :only => [:index]

    match "/status"  => "ping#status", :via => :get
    match "/version"  => "ping#version", :via => :get 
    # some paths conflicts with rhsm
    scope 'katello' do

      # routes for non-ActiveRecord-based resources
      match '/products/:id/repositories' => 'products#repo_create', :via => :post, :constraints => { :id => /[0-9\.]*/ }

    end

    # support for rhsm --------------------------------------------------------
    match '/consumers' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
    match '/hypervisors' => 'systems#hypervisors_update', :via => :post
    resources :consumers, :controller => 'systems'
    match '/owners/:organization_id/environments' => 'environments#index', :via => :get
    match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get
    match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
    match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
    match '/users/:username/owners' => 'users#list_owners', :via => :get

    # proxies -------------------
      # candlepin proxy ---------
    match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/release' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/certificates/serials' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post
    match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete
    match '/consumers/:id/entitlements/dry-run' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/owner' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete
    match '/consumers/:id/deletionrecord' => 'candlepin_proxies#delete', :via => :delete
    match '/pools' => 'candlepin_proxies#get', :via => :get
    match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get
    match '/subscriptions' => 'candlepin_proxies#post', :via => :post

      # pulp proxy --------------
    match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put
    match '/consumers/:id/packages/' => 'systems#upload_package_profile', :via => :put

    # development / debugging support
    if Rails.env == "development"
      get 'status/memory'
    end

    match '*a', :to => 'errors#render_404'
  # end '/api' namespace
  end


  #Last route in routes.rb - throws routing error for everything not handled
  match '*a', :to => 'errors#routing'
end
