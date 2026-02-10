Katello::Engine.routes.draw do
  scope :katello, :path => '/katello' do
    match ':kt_path/auto_complete_search', :action => :auto_complete_search, :controller => :auto_complete_search, :via => :get

    match '/remote_execution' => 'remote_execution#create', :via => [:post]
  end

  get '/katello/providers/redhat_provider', to: redirect('/redhat_repositories')
  get '/content_hosts', to: redirect(Rails.application.routes.url_helpers.new_hosts_index_page_path)

  # Redirect legacy content host detail pages to new host details
  # Note: :id can be either hostname or database ID (friendly-id gem)
  constraints(id: /[^\/]+/) do
    get '/content_hosts/:id', to: redirect { |params, _|
      # The friendly-id gem allows both name and ID to work, so just pass through
      host_identifier = params[:id]
      Rails.application.routes.url_helpers.host_details_page_path(host_identifier)
    }
    get '/content_hosts/:id/:tab', to: redirect { |params, _|
      host_identifier = params[:id]
      tab_map = {
        'errata' => 'errata',
        'packages' => 'packages',
        'debs' => 'debs',
        'module-streams' => 'module-streams',
      }
      top_level_tab_map = {
        'traces' => 'Traces',
      }
      fragment = tab_map[params[:tab]].present? ? "#/Content/#{tab_map[params[:tab]]}" : ''
      fragment = "#/#{top_level_tab_map[params[:tab]]}" if top_level_tab_map[params[:tab]].present?
      "#{Rails.application.routes.url_helpers.host_details_page_path(host_identifier)}#{fragment}"
    }
  end

  match '/redhat_repositories' => 'react#index', :via => [:get]

  get '/katello/sync_management', to: redirect('/sync_management')
  match '/sync_management' => 'react#index', :via => [:get]

  match '/subscriptions' => 'react#index', :via => [:get]
  match '/subscriptions/*page' => 'react#index', :via => [:get]

  match '/module_streams' => 'react#index', :via => [:get]
  match '/module_streams/*page' => 'react#index', :via => [:get]

  match '/legacy_ansible_collections' => 'react#index', :via => [:get]
  match '/legacy_ansible_collections/*page' => 'react#index', :via => [:get]

  match '/content_views' => 'react#index', :via => [:get]
  match '/content_views/*page' => 'react#index', :via => [:get]

  match '/content' => 'react#index', :via => [:get]

  match '/alternate_content_sources' => 'react#index', :via => [:get]
  match '/alternate_content_sources/*page' => 'react#index', :via => [:get]

  match '/booted_container_images' => 'react#index', :via => [:get]

  match '/container_images' => 'react#index', :via => [:get]
  match '/container_images/*page' => 'react#index', :via => [:get]

  match '/flatpak_remotes' => 'react#index', :via => [:get]
  match '/flatpak_remotes/*page' => 'react#index', :via => [:get]

  Katello::RepositoryTypeManager.generic_ui_content_types(false).each do |type|
    get "/#{type.pluralize}", to: redirect("/content/#{type.pluralize}")
    get "/#{type.pluralize}/:page", to: redirect("/content/#{type.pluralize}/%{page}")
    match "/content/#{type.pluralize}" => 'react#index', :via => [:get]
    match "/content/#{type.pluralize}/*page" => 'react#index', :via => [:get]
  end

  match '/labs' => 'react#index', :via => [:get]
  match '/labs/*page' => 'react#index', :via => [:get]
  match '/organization_select' => 'react#index', :via => [:get]

  get '/change_host_content_source', to: 'react#index'
  constraints(id: /[^\/]+/) do
    get 'new/hosts/:id/content', to: redirect('new/hosts/%{id}#/Content')
  end
end
