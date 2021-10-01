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

  match '/module_streams' => 'react#index', :via => [:get]
  match '/module_streams/*page' => 'react#index', :via => [:get]

  match '/ansible_collections' => 'react#index', :via => [:get]
  match '/ansible_collections/*page' => 'react#index', :via => [:get]

  match '/content' => 'react#index', :via => [:get]

  Katello::RepositoryTypeManager.generic_content_types.each do |type|
    get "/#{type.pluralize}", to: redirect("/content/#{type.pluralize}")
    get "/#{type.pluralize}/:page", to: redirect("/content/#{type.pluralize}/%{page}")
    match "/content/#{type.pluralize}" => 'react#index', :via => [:get]
    match "/content/#{type.pluralize}/*page" => 'react#index', :via => [:get]
  end

  match '/labs' => 'react#index', :via => [:get]
  match '/labs/*page' => 'react#index', :via => [:get]
  match '/organization_select' => 'react#index', :via => [:get]
end
