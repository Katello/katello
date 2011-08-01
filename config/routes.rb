Src::Application.routes.draw do

  resources :activation_keys do
    collection do
      get :auto_complete_search
      get :items
      get :subscriptions
    end
    member do
      get :subscriptions
      post :update_subscriptions
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
  match 'notices/:id/details' => 'notices#details', :via => :get
  match 'notices' => 'notices#show', :via => :get
  match 'notices' => 'notices#destroy_all', :via => :delete

  resources :subscriptions do
  end

  resources :dashboard do
  end
  resources :content do
  end
  resources :systems do
    member do
      get :packages
      get :subscriptions
      post :update_subscriptions
      get :facts
    end
    collection do
      get :auto_complete_search
      get :items
      get :environments
    end
  end
  resources :operations do
  end

  resources :packages do
    member do
      get :changelog
      get :filelist
      get :dependencies
    end
  end

  resources :errata do
    member do
      get :packages
    end
  end

  resources :products do
    member do
      get :sync
    end
  end

  resources :owners do
    member do
      post :import
      get :import_status
    end
  end
  match '/consumers/export_status' => 'consumers#export_status', :via => :get

  resources :consumers do
    member do
      get :export
    end
    resources :entitlements
    resources :certificates do
      collection do
        get :serials
      end
    end
  end
  match '/consumers/:id' => 'consumers#re_register', :via => :post

  resources :entitlements
  resources :users do
    collection do
      get :auto_complete_search
      get :items
      post :enable_helptip
      post :disable_helptip
    end
    member do
      post :clear_helptips
    end
  end

  resources :nodes, :constraints => {:id => /[^\/]+/}, :only => [:index, :show]
  resources :puppetclasses, :only => [:index]
  resources :providers do
    resources :products do
      resources :repositories
    end
    collection do
      get :items
    end
    member do
      get :products_repos
      get :subscriptions
      post :subscriptions
      get :schedule
    end
  end
  match '/providers/:id' => 'providers#update', :via => :put
  match '/providers/:id' => 'providers#update', :via => :post

  match '/organizations/:org_id/environments/:env_id/promotions' => 'promotions#show', :via=>:get, :as=>'promotions'
  match '/organizations/:org_id/environments/:env_id/promotions/products' => 'promotions#products', :via=>:get, :as=>'promotion_products'
  match '/organizations/:org_id/environments/:env_id/promotions/packages' => 'promotions#packages', :via=>:get, :as=>'promotion_packages'
  match '/organizations/:org_id/environments/:env_id/promotions/errata' => 'promotions#errata', :via=>:get, :as=>'promotion_errata'
  match '/organizations/:org_id/environments/:env_id/promotions/repos' => 'promotions#repos', :via=>:get, :as=>'promotion_repos'
  match '/organizations/:org_id/environments/:env_id/promotions/detail' => 'promotions#detail', :via=>:get, :as=>'promotion_details'
  match '/organizations/:org_id/environments/:env_id/edit' => 'environments#update', :via => :put

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
      get :products
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
    post "create_permission" => "roles#create_permission"

    resources :permission, :only => {} do
      put "update_permission" => "roles#update_permission", :as => "update"
    end
    collection do
      get :auto_complete_search
      get :items
    end
  end
  match '/roles/resource_type/:resource_type/verbs_and_scopes' => 'roles#verbs_and_scopes', :via=>:get, :as=>'verbs_and_scopes'

  resources :search, :only => {} do
    get 'show', :on => :collection

    get 'history', :on => :collection
    delete 'history' => 'search#destroy_history', :on => :collection

    get 'favorite', :on => :collection
    post 'favorite' => 'search#create_favorite', :on => :collection
    delete 'favorite/:id' => 'search#destroy_favorite', :on => :collection, :as => 'destroy_favorite'
  end

  resource :user_session do
    get 'invalid'
  end

  resource :account
  root :to => "user_sessions#new"

  match '/login' => 'user_sessions#new'
  match '/logout' => 'user_sessions#destroy'
  match '/user_session/logout' => 'user_sessions#destroy'
  match '/user_session' => 'user_sessions#show', :via=>:get, :as=>'show_user_session'


  namespace :api do
    match '/' => 'root#resource_list'

    resources :systems, :only => [:show, :destroy, :create, :index] do
      member do
        get :packages
      end
    end

    resources :providers do
      resources :sync, :only => [:index, :show, :create] do
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

    #match '/organizations/:organization_id/locker/repos' => 'environments#repos', :via => :get
    resources :organizations do
      resources :products, :only => [:index] do
        get :repositories, :on => :member
      end
      resources :environments do
        get :repositories, :on => :member
        resources :changesets, :only => [:index, :show, :create, :destroy] do
          put :update, :on => :member, :action => :update_content
          post :promote, :on => :member, :action => :promote
        end
      end
      resources :tasks, :only => [:index]
      member do
        get :providers
      end
      resources :systems, :only => [:index]
      resources :activation_keys, :only => [:index]
    end

    resources :products, :only => [] do
      get :repositories, :on => :member
      resources :sync, :only => [:index, :show, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
    end

    resources :puppetclasses, :only => [:index]
    resources :ping, :only => [:index]

    resources :repositories, :only => [:index, :show, :create], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
      resources :sync, :only => [:index, :show, :create] do
        delete :index, :on => :collection, :action => :cancel
      end
      resources :packages, :only => [:index]
      resources :errata, :only => [:index]
      resources :distributions, :only => [:index]
    end
    match '/repositories/discovery' => 'repositories#discovery', :via => :post
    match '/repositories/discovery/:id' => 'repositories#discovery_status', :via => :get

    resources :environments, :only => [:show, :update, :destroy] do
      resources :systems, :only => [:create, :index]
      resources :products, :only => [:index] do
        get :repositories, :on => :member
      end
      resources :activation_keys, :only => [:index, :create]
    end

    resources :activation_keys, :only => [:show, :update, :destroy]
    resources :packages, :only => [:show]
    resources :changesets, :only => [:show]
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
    resources :consumers, :controller => 'systems'
    match '/owners/:organization_id/environments' => 'environments#index', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
    match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
    match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
    
    # proxies -------------------
      # candlepin proxy ---------
    match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/certificates/serials' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post
    match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete
    match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete
    match '/pools' => 'candlepin_proxies#get', :via => :get
    match '/products' => 'candlepin_proxies#get', :via => :get
    match '/products/:id' => 'candlepin_proxies#get', :via => :get
    match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get
    match '/subscriptions' => 'candlepin_proxies#post', :via => :post
    match '/users/:username/owners' => 'organizations#list_owners', :via => :get
    
      # pulp proxy --------------
    match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put

    # development / debugging support
    get 'status/memory'

  # end '/api' namespace
  end
end
