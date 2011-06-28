Src::Application.routes.draw do

  get "sync_plans/auto_complete_search"
  resources :sync_plans, :only => [:index, :create, :new, :edit, :update, :show, :destroy] do
    collection do
      get :items
    end
  end

  get  "sync_schedules/index"
  post "sync_schedules/apply"

  get "sync_management/index"
  post "sync_management/sync"
  get  "sync_management/status"
  get  "sync_management/product_status"
  resources :sync_management, :only => [:destroy]

  get "notices/note_count"
  get "notices/get_new"
  get "notices/auto_complete_search"
  match 'notices/:id/details' => 'notices#details', :via => :get
  match 'notices' => 'notices#show', :via => :get
  match 'notices' => 'notices#destroy_all', :via => :delete

  resources :dashboard do
  end
  resources :content do
  end
  resources :systems do
    get 'auto_complete_search' , :on => :collection
    member do
      get :packages
      get :subscriptions
      post :update_subscriptions
      get :facts
    end
    collection do
      get :items
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
  resources :pools
  resources :users do
    get 'auto_complete_search' , :on => :collection
    collection do
      get :items
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
    get 'auto_complete_search' , :on => :collection

    resources :environments
    resources :providers do
      get 'auto_complete_search', :on => :collection
    end
    resources :providers
    collection do
      get :items
    end
  end
  match '/organizations/:id/edit' => 'organizations#update', :via => :put

  resources :changesets, :only => [:update, :index, :show, :create, :edit, :show, :auto_complete_search] do
    get 'auto_complete_search', :on => :collection

    member do
      put :name
      get :dependency_size
      get :dependency_list
      post :promote
    end
    collection do
      get :list
      get :items
    end
  end


  resources :environments

  resource :user
  match '/users/:id/edit' => 'users#update', :via => :put
  match 'users/:id/delete' => 'users#delete', :via=> :post
  match '/users/:id/clear_helptips' => 'users#clear_helptips', :via => :post
  match '/users/enable_helptip' => 'users#enable_helptip', :via=>:post
  match '/users/disable_helptip' => 'users#disable_helptip', :via=>:post

  match '/roles/show_permission' => 'roles#show_permission', :via=>:get
  resources :roles do
    get 'auto_complete_search' , :on => :collection
    post "create_permission" => "roles#create_permission"

    resources :permission, :only => {} do
      put "update_permission" => "roles#update_permission", :as => "update"
    end
    collection do
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

  resource :user_session
  resource :account
  root :to => "user_sessions#new"

  match '/login' => 'user_sessions#new'
  match '/logout' => 'user_sessions#destroy'
  match '/user_session/logout' => 'user_sessions#destroy'

  namespace :api do

    resources :systems, :only => [:show, :destroy, :create]
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
      resources :products, :only => [:index]
      resources :environments do
        resources :products, :only => [:index], :constraints => { :id => /[0-9\.]*/ } do
          get :repositories, :on => :member
          resources :sync, :only => [:index, :show, :create] do
            delete :index, :on => :collection, :action => :cancel
          end
        end
        member do
          get :repositories
        end
      end
      resources :systems, :only => [:index]
      member do
        get :providers
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

    resources :packages, :only => [:show]
    resources :errata, :only => [:show]
    resources :distributions, :only => [:show]

    # some paths conflicts with rhsm
    scope 'katello' do

      # routes for non-ActiveRecord-based resources
      match '/products/:id/repositories' => 'products#repo_create', :via => :post, :constraints => { :id => /[0-9\.]*/ }

    end

    # support for rhsm
    resources :consumers, :controller => 'systems'
    match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
    match '/consumers/:id/certificates' => 'proxies#get', :via => :get
    match '/consumers/:id/certificates/serials' => 'proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'proxies#get', :via => :get
    match '/consumers/:id/entitlements' => 'proxies#post', :via => :post
    match '/consumers/:id/entitlements' => 'proxies#delete', :via => :delete
    match '/consumers/:consumer_id/certificates/:id' => 'proxies#delete', :via => :delete
    match '/pools' => 'proxies#get', :via => :get
    match '/products' => 'proxies#get', :via => :get
    match '/products/:id' => 'proxies#get', :via => :get
    match '/entitlements/:id' => 'proxies#get', :via => :get
    match '/subscriptions' => 'proxies#post', :via => :post

    # development / debugging support
    get 'status/memory'

  end
end
