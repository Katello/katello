module Katello
  class WhitelistConstraint
    PATHS ||= [%r{\A/api/v2/organizations/\S+/parameters}].freeze

    def matches?(request)
      PATHS.map { |path| request.env["REQUEST_PATH"].try(:match, path) }.any? ? false : true
    end
  end
end

Foreman::Application.routes.draw do
  override_message = '{"message": "Route overriden by Katello, use the /katello API endpoint instead.  See /apidoc for more details."}'

  match "/api/v2/organizations/*all", :to => proc { [404, {}, [override_message]] },
                                      :via => :put,
                                      :constraints => Katello::WhitelistConstraint.new

  match "/api/v2/organizations", :to => proc { [404, {}, [override_message]] },
                                      :via => :post,
                                      :constraints => Katello::WhitelistConstraint.new

  match "/api/v2/organizations/:id", via: :delete, to: proc { [404, {}, [override_message]] }

  resources :hosts, :only => [] do
    get :content_hosts, :on => :collection
  end

  resources :smart_proxies, :only => [] do
    member do
      get :pulp_storage
      get :pulp_status
    end
  end

  post '/change_host_content_source/data', to: 'hosts#change_content_source_data'

  namespace :api do
    scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
      match '/hosts/post_index' => 'hosts#index', :via => :post

      resources :hosts, :only => [] do
        member do
          put :host_collections
        end
      end
    end
  end

  scope :module => "katello" do
    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        resources :hosts, :only => [] do
          resources :errata, :only => [:show, :index], :controller => :host_errata do
            collection do
              put :apply
              get :auto_complete_search
              put :applicability
            end
          end

          collection do
            match '/auto_complete_search' => 'host_autocomplete#auto_complete_search', :via => :get
            match '/bulk/add_host_collections' => 'hosts_bulk_actions#bulk_add_host_collections', :via => :put
            match '/bulk/remove_host_collections' => 'hosts_bulk_actions#bulk_remove_host_collections', :via => :put
            match '/bulk/remove_host_collections' => 'hosts_bulk_actions#bulk_remove_host_collections', :via => :put

            match '/bulk/add_subscriptions' => 'hosts_bulk_actions#add_subscriptions', :via => :put
            match '/bulk/remove_subscriptions' => 'hosts_bulk_actions#remove_subscriptions', :via => :put
            match '/bulk/auto_attach' => 'hosts_bulk_actions#auto_attach', :via => :put
            match '/bulk/content_overrides' => 'hosts_bulk_actions#content_overrides', :via => :put

            match '/bulk/install_content' => 'hosts_bulk_actions#install_content', :via => :put
            match '/bulk/applicable_errata' => 'hosts_bulk_actions#applicable_errata', :via => :post
            match '/bulk/installable_errata' => 'hosts_bulk_actions#installable_errata', :via => :post
            match '/bulk/update_content' => 'hosts_bulk_actions#update_content', :via => :put
            match '/bulk/remove_content' => 'hosts_bulk_actions#remove_content', :via => :put
            match '/bulk/destroy' => 'hosts_bulk_actions#destroy_hosts', :via => :put
            match '/bulk/environment_content_view' => 'hosts_bulk_actions#environment_content_view', :via => :put
            match '/bulk/release_version' => 'hosts_bulk_actions#release_version', :via => :put
            match '/bulk/traces' => 'hosts_bulk_actions#traces', :via => :post
            match '/bulk/resolve_traces' => 'hosts_bulk_actions#resolve_traces', :via => :put
            match '/bulk/system_purpose' => 'hosts_bulk_actions#system_purpose', :via => :put
            match '/bulk/available_incremental_updates' => 'hosts_bulk_actions#available_incremental_updates', :via => :post
            match '/bulk/module_streams' => 'hosts_bulk_actions#module_streams', :via => :post
            match '/bulk/change_content_source' => 'hosts_bulk_actions#change_content_source', :via => :put
            match '/subscriptions/' => 'host_subscriptions#create', :via => :post
          end

          resources :packages, :only => [:index], :controller => :host_packages do
            get :auto_complete_search, :on => :collection

            collection do
              put :remove
              put :install
              put :upgrade
              put :upgrade_all
            end
          end

          resources :module_streams, :only => [:index], :controller => :host_module_streams do
            get :auto_complete_search, :on => :collection
          end

          resources :debs, :only => [:index], :controller => :host_debs do
            get :auto_complete_search, :on => :collection
          end

          resources :subscriptions, :only => [:index], :controller => :host_subscriptions do
            collection do
              put :auto_attach
              match '/product_content' => 'repository_sets#index', :via => :get, :entity => :host
              get :available_release_versions
              get :enabled_repositories
              put :content_override
              put :remove_subscriptions
              put :add_subscriptions
              delete :destroy
            end
          end

          resources :traces, :only => [:index], :controller => :host_tracer do
            get :auto_complete_search, :on => :collection

            collection do
              put :resolve
            end
          end
        end
      end
    end
  end
end
