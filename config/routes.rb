Src::Application.routes.draw do

  resources :activation_keys do
    collection do
      get :auto_complete_search
      get :items
      get :subscriptions
    end
    member do
      get :subscriptions
      get :edit_environment
      post :update
      post :update_subscriptions
    end
  end

  resource :account

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


  resources :systems, :except => [:destroy] do
    member do
      get :packages
      get :more_packages
      get :subscriptions
      post :update_subscriptions
      get :facts
    end
    collection do
      get :auto_complete_search
      get :items
      get :env_items
      get :environments
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
  end

  resources :errata, :only => [:show] do
    member do
      get :packages
    end
  end

  resources :distributions, :only => [:show] do
    member do
      get :filelist
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
    end
  end

  resources :system_templates do
    collection do
      get :auto_complete_search
      get :items
      get :auto_complete_package
      get :product_packages
    end
    member do
      get :promotion_details
      get :object
      get :download
      put :update_content
    end
  end


  resources :providers do
    resources :products do
      resources :repositories
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
  match '/organizations/:org_id/environments/:env_id/system_templates' => 'environments#system_templates', :via => :get, :as => 'system_templates_organization_environment'

  resources :organizations do
    resources :environments
    resources :providers do
      get 'auto_complete_search', :on => :collection
    end
    resources :providers
    collection do
      get :auto_complete_search
      get :items
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

  resource :account

  root :to => "user_sessions#new"

  match '/login' => 'user_sessions#new'
  match '/logout' => 'user_sessions#destroy', :via=>:post
  match '/user_session/logout' => 'user_sessions#destroy'
  match '/user_session' => 'user_sessions#show', :via=>:get, :as=>'show_user_session'



  namespace :api do
    class RegisterWithActivationKeyContraint
      def matches?(request)
        request.params[:activation_keys]
      end
    end
    match '/' => 'root#resource_list'

    resources :systems, :only => [:show, :destroy, :create, :index, :update] do
      member do
        get :packages, :action => :package_profile
        get :errata
      end
    end
    match '/systems/:id/subscription' => 'systems#subscribe', :via => :post

    resources :providers, :except => [:index] do
      resources :sync, :only => [:index, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
      member do
        post :import_products
        post :import_manifest
        post :product_create
        get :products
      end
    end

    resources :templates do
      post :promote, :on => :member
      put :update_content, :on => :member
      post :import, :on => :collection
      get :export, :on => :member
    end

    resources :organizations do
      resources :products, :only => [:index] do
        get :repositories, :on => :member
      end
      resources :environments do
        get :repositories, :on => :member
        resources :changesets, :only => [:index, :create]
      end
      resources :tasks, :only => [:index]
      resources :providers, :only => [:index]
      resources :systems, :only => [:index]
      match '/systems' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
      resources :activation_keys, :only => [:index]
      resources :repositories, :only => [] do
        post :discovery, :on => :collection
      end
      resource :uebercert, :only => [:create, :show]
      resources :filters, :only => [:index, :create, :destroy, :show]
    end

    resources :changesets, :only => [:show, :destroy] do
      put :update, :on => :member, :action => :update_content
      post :promote, :on => :member, :action => :promote
    end

    resources :products, :only => [:show] do
      get :repositories, :on => :member
      resources :sync, :only => [:index, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
    end

    resources :puppetclasses, :only => [:index]
    resources :ping, :only => [:index]

    resources :repositories, :only => [:index, :show, :create], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
      resources :sync, :only => [:index, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
      resources :packages, :only => [:index]
      resources :errata, :only => [:index]
      resources :distributions, :only => [:index]
      member do
        get :package_groups
        get :package_group_categories
      end
    end

    resources :environments, :only => [:show, :update, :destroy] do
      resources :systems, :only => [:create, :index]
      resources :products, :only => [:index] do
        get :repositories, :on => :member
      end
      resources :activation_keys, :only => [:index, :create]
      resources :templates, :only => [:index]
    end

    resources :activation_keys, :only => [:show, :update, :destroy]
    resources :packages, :only => [:show]
    resources :errata, :only => [:show]
    resources :distributions, :only => [:show]

    resources :users

    resources :tasks, :only => [:show]

    # some paths conflicts with rhsm
    scope 'katello' do

      # routes for non-ActiveRecord-based resources
      match '/products/:id/repositories' => 'products#repo_create', :via => :post, :constraints => { :id => /[0-9\.]*/ }

    end

    # support for rhsm --------------------------------------------------------
    match '/consumers' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
    resources :consumers, :controller => 'systems'
    match '/owners/:organization_id/environments' => 'environments#index', :via => :get
    match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
    match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
    match '/users/:username/owners' => 'users#list_owners', :via => :get

    # proxies -------------------
      # candlepin proxy ---------
    match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/certificates/serials' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post
    match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete
    match '/consumers/:id/owner' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete
    match '/pools' => 'candlepin_proxies#get', :via => :get
    match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get
    match '/subscriptions' => 'candlepin_proxies#post', :via => :post

      # pulp proxy --------------
    match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put
    match '/consumers/:id/packages/' => 'systems#upload_package_profile', :via => :put

    # development / debugging support
    get 'status/memory'

  # end '/api' namespace
  end


  #Last route in routes.rb - throws routing error for everything not handled
  match '*a', :to => 'errors#routing'
end
