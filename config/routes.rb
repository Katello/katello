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
    end

    resources :providers, :only => [] do
      collection do
        get :redhat_provider
        get :redhat_provider_tab
      end
    end

    if Katello.with_remote_execution?
      match '/remote_execution' => 'remote_execution#create', :via => [:post]
    end
  end

  if Setting[:katello_experimental_ui]
    match '/redhat_repositories' => 'react#index', :via => [:get]
  end
end
