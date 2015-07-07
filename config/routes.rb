Katello::Engine.routes.draw do
  scope :katello, :path => '/katello' do
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
        get :repo_compare_puppet_modules
        get :view_compare_packages
        get :view_compare_puppet_modules
      end
    end

    match ':kt_path/auto_complete_search', :action => :auto_complete_search, :controller => :auto_complete_search, :via => :get

    resources :content_views, :only => [:index] do
      collection do
        get :auto_complete
      end
    end

    resources :sync_management, :only => [:destroy] do
      collection do
        get :index
        get :sync_status
        post :sync
      end
    end

    resources :dashboard, :only => [:index] do
      collection do
        get :sync
        get :errata
        get :content_views
        get :promotions
        get :host_collections
        get :subscriptions
        get :subscriptions_totals
        put :update
      end
    end

    resources :packages, :only => [:show] do
      member do
        get :details
      end
      collection do
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
      end
      collection do
        get :auto_complete
        get :items
        get :env_items
        get :environments
        delete :bulk_destroy
      end
    end

    resources :errata, :only => [:show] do
      collection do
        get :auto_complete
      end
      member do
        get :short_details
      end
    end

    resources :products, :only => [] do
      member do
        get :available_repositories
        put :toggle_repository
      end
      collection do
        get :auto_complete
        get :all
      end
    end

    resources :providers do
      collection do
        get :auto_complete_search
        get :redhat_provider
        get :redhat_provider_tab
      end
    end

    match '/providers/:id' => 'providers#update', :via => [:put, :post]

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

    root :to => "dashboard#index"

    match '/403' => 'application#permission_denied', :via => :get
  end
end
