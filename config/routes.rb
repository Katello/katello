Katello::Engine.routes.draw do
  scope :katello, :path => '/katello' do
    match ':kt_path/auto_complete_search', :action => :auto_complete_search, :controller => :auto_complete_search, :via => :get

    resources :sync_management, :only => [:destroy] do
      collection do
        get :index
        get :sync_status
        post :sync
      end
    end

    resources :products, :only => [] do
      member do
        get :available_repositories
        put :toggle_repository
      end
      collection do
        get :all
      end
    end

    resources :providers do
      collection do
        get :redhat_provider
        get :redhat_provider_tab
      end
    end

    match '/providers/:id' => 'providers#update', :via => [:put, :post]

    if Katello.with_remote_execution?
      match '/remote_execution' => 'remote_execution#create', :via => [:post]
    end

    resources :organizations do
      collection do
        get :auto_complete_search
        get :items
        get :default_label
      end
      member do
        get :show
        get :events
        get :download_debug_certificate
      end
    end
    match '/organizations/:id/edit' => 'organizations#update', :via => :put

    resources :search, :only => {} do
      get 'show', :on => :collection

      get 'history', :on => :collection
      delete 'history' => 'search#destroy_history', :on => :collection

      get 'favorite', :on => :collection
      post 'favorite' => 'search#create_favorite', :on => :collection
      delete 'favorite/:id' => 'search#destroy_favorite', :on => :collection, :as => 'destroy_favorite'
    end

    match '/403' => 'application#permission_denied', :via => :get
  end
end
