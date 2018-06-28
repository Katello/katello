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

    if Katello.with_remote_execution?
      match '/remote_execution' => 'remote_execution#create', :via => [:post]
    end
  end

  get '/katello/providers/redhat_provider', to: redirect('/redhat_repositories')
  match '/redhat_repositories' => 'react#index', :via => [:get]

  match '/subscriptions' => 'react#index', :via => [:get]
  match '/subscriptions/*page' => 'react#index', :via => [:get]

  match '/xui' => 'react#index', :via => [:get]
  match '/xui/*page' => 'react#index', :via => [:get]
end
