Foreman::Application.routes.draw do
  match "/api/v2/organizations/*all", to: proc { [404, {}, ['']] }, :via => :get
  match "/api/v1/organizations/:id", via: :delete, to: proc { [404, {}, ['']] }

  resources :operatingsystems, :only => [] do
    get 'available_kickstart_repo', :on => :member
  end

  resources :hosts, :only => [] do
    get 'puppet_environment_for_content_view', :on => :collection
  end
end
