class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

# rubocop:disable Metrics/BlockLength
Katello::Engine.routes.draw do
  scope :katello, :path => '/katello' do
    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        ##############################
        # re-routes alphabetical
        ##############################

        api_resources :alternate_content_sources, :only => [:index, :show, :create, :update, :destroy] do
          get :auto_complete_search, :on => :collection
        end

        api_resources :flatpak_remotes, :only => [:index, :show, :create, :update, :destroy] do
          get :auto_complete_search, :on => :collection
          member do
            post :scan
          end
          api_resources :flatpak_remote_repositories, :only => [:index, :show]
        end

        api_resources :flatpak_remote_repositories, :only => [:index, :show] do
          get :auto_complete_search, :on => :collection
          member do
            post :mirror
          end
        end

        api_resources :host_bootc_images, :only => [:auto_complete_search] do
          get :auto_complete_search, :on => :collection
        end

        api_resources :capsules, :only => [:index, :show] do
          member do
            resource :content, :only => [], :controller => 'capsule_content' do
              get :lifecycle_environments
              get :available_lifecycle_environments
              get :counts
              post :update_counts
              post :sync
              get :sync, :action => :sync_status
              delete :sync, :action => :cancel_sync
              post :reclaim_space
              post :verify_checksum
              post '/lifecycle_environments' => 'capsule_content#add_lifecycle_environment'
              delete '/lifecycle_environments/:environment_id' => 'capsule_content#remove_lifecycle_environment'
            end
          end
        end

        api_resources :activation_keys, :only => [:index, :create, :show, :update, :destroy] do
          get :auto_complete_search, :on => :collection
          member do
            match '/product_content' => 'repository_sets#index', :via => :get, :entity => :activation_key
            match '/content_override' => 'activation_keys#content_override', :via => :put
            post :copy
            put :add_subscriptions
            put :remove_subscriptions
          end
          match '/releases' => 'activation_keys#available_releases', :via => :get, :on => :member
          api_resources :host_collections, :only => [:index]
          member do
            match '/host_collections' => 'activation_keys#add_host_collections', :via => :post
            match '/host_collections' => 'activation_keys#remove_host_collections', :via => :put
            match '/host_collections/available' => 'activation_keys#available_host_collections', :via => :get
          end
          api_resources :products, :only => [:index]
          api_resources :subscriptions, :only => [:index] do
            collection do
              match '/available' => 'subscriptions#available', :via => :get
            end
          end
        end

        api_resources :content_credentials, :only => [:index, :show, :create, :update, :destroy] do
          member do
            get :content
            post :content, :action => :set_content
          end
          get :auto_complete_search, :on => :collection
        end

        match '/content_views/:composite_content_view_id/content_view_components' => 'content_view_components#index', :via => :get
        match '/content_views/:composite_content_view_id/content_view_components/show_all' => 'content_view_components#show_all', :via => :get
        match '/content_views/:composite_content_view_id/content_view_components/:id' => 'content_view_components#show', :via => :get
        match '/content_views/:composite_content_view_id/content_view_components/add' => 'content_view_components#add_components', :via => :put
        match '/content_views/:composite_content_view_id/content_view_components/remove' => 'content_view_components#remove_components', :via => :put
        match '/content_views/:composite_content_view_id/content_view_components/:id' => 'content_view_components#update', :via => :put

        api_resources :content_view_environments, :only => [:index]

        api_resources :content_views do
          get :auto_complete_search, :on => :collection
          member do
            post :copy
            post :publish
            put :remove
            put :bulk_delete_versions
            put :remove_filters
            match '/environments/:environment_id' => "content_views#remove_from_environment", :via => :delete
          end
          api_resources :filters, :controller => :content_view_filters do
            member do
              put :remove_filter_rules
              put :add_filter_rules
            end
            collection do
              get :auto_complete_search
            end
            api_resources :errata, :only => [:index]
            api_resources :package_groups, :only => [:index]
          end
          api_resources :history, :controller => :content_view_histories, :only => [:index] do
            collection do
              get :auto_complete_search
            end
          end
          api_resources :repositories, :only => [:index] do
            collection do
              match '/show_all' => "content_view_repositories#show_all", :via => :get
            end
          end
          api_resources :content_view_versions, :only => [:index]
        end

        api_resources :content_view_filters do
          member do
            put :remove_filter_rules
            put :add_filter_rules
          end
          api_resources :errata, :only => [:index]
          api_resources :package_groups, :only => [:index]
          api_resources :rules, :controller => :content_view_filter_rules do
            collection do
              get :auto_complete_search
            end
          end
          collection do
            get :auto_complete_search
          end
        end

        api_resources :content_exports, :only => [:index] do
          collection do
            post :version
            post :library
            post :repository
            get :index
          end
        end

        api_resources :content_imports, :only => [:index]

        api_resources :content_export_incrementals, :only => [] do
          collection do
            post :version
            post :library
            post :repository
          end
        end

        api_resources :content_view_versions, :except => [:create] do
          member do
            post :promote
            post :export
            put :republish_repositories
            post :verify_checksum
          end
          collection do
            get :auto_complete_search
            post :incremental_update
          end
        end

        api_resources :content_imports, :only => [] do
          collection do
            post :version
            post :library
            post :repository
          end
        end

        api_resources :ansible_collections, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :debs, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :auto_complete_name
            get :auto_complete_arch
            get :compare
          end
        end

        api_resources :docker_manifests, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :docker_manifest_lists, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :docker_tags, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :auto_complete_name
            get :compare
          end
          member do
            get :repositories
          end
        end

        api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
          api_resources :activation_keys, :only => [:index, :create]
        end

        api_resources :errata, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :host_collections, :only => [:index, :show, :create, :update, :destroy] do
          member do
            post :copy
            put :add_hosts
            put :remove_hosts
          end
          get :auto_complete_search, :on => :collection
        end

        api_resources :module_streams, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :auto_complete_name
            get :compare
          end
        end

        api_resources :organizations, :only => [:index, :show, :update, :create, :destroy] do
          api_resources :activation_keys, :only => [:index]
          api_resources :content_views, :only => [:index, :create]
          api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
            api_resources :repositories, :only => [:index]
            collection do
              get :paths
              get :auto_complete_search
            end
          end
          api_resources :host_collections, :only => [:index, :create]
          member do
            post :repo_discover
            post :cancel_repo_discover
            get :download_debug_certificate
            get :redhat_provider
            get :releases
            put :cdn_configuration
          end
          api_resources :products, :only => [:index]
          api_resources :repositories, :only => [:index]
          api_resources :alternate_content_sources, :only => [:index]
          api_resources :subscriptions, :only => [:index] do
            collection do
              match '/available' => 'subscriptions#available', :via => :get
              get :auto_complete_search
              get :manifest_history
            end
          end
          api_resources :flatpak_remotes, :only => [:index, :show]
          api_resources :flatpak_remote_repositories, :only => [:index, :show]
        end

        match "/packages/thindex" => "packages#thindex", :via => :get

        api_resources :packages, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :auto_complete_name
            get :auto_complete_arch
            get :compare
          end
        end

        api_resources :package_groups, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :files, :only => [:index, :show], :controller => 'file_units' do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        Katello::RepositoryTypeManager.generic_content_types(false).each do |type|
          api_resources type.pluralize.to_sym, :only => [:index, :show], :controller => 'generic_content_units', :content_type => type do
            collection do
              get :auto_complete_search
              get :compare
            end
          end
        end
        api_resources :content_units, :only => [:index, :show], :controller => 'generic_content_units'

        match "/ping" => "katello_ping#index", :via => :get
        match "/status" => "katello_ping#server_status", :via => :get

        api_resources :products, :only => [:index, :show, :create, :update, :destroy] do
          member do
            post :sync
          end
          collection do
            get :auto_complete_search
            get :auto_complete_name
          end
          api_resources :repository_sets, :only => [:index, :show] do
            get :auto_complete_search, :on => :collection
            member do
              get :available_repositories
              put :enable
              put :disable
            end
          end
        end

        api_resources :repositories, :only => [:index, :create, :show, :destroy, :update] do
          collection do
            get :auto_complete_search
            get :repository_types
            get :content_types
            get :compare
          end
          member do
            put :republish
          end
        end

        api_resources :repository_sets, :only => [:index, :show] do
          get :auto_complete_search, :on => :collection
          member do
            get :available_repositories
            put :enable
            put :disable
          end
        end

        api_resources :srpms, :only => [:index, :show], :controller => 'srpms' do
          collection do
            get :auto_complete_search
            get :compare
          end
        end

        api_resources :subscriptions, :only => [:index, :show] do
          collection do
            get :auto_complete_search
          end
        end

        ##############################
        ##############################

        match '/alternate_content_sources/bulk/refresh_all' => 'alternate_content_sources_bulk_actions#refresh_all_alternate_content_sources', :via => :post

        api_resources :alternate_content_sources, :only => [], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
          collection do
            match '/bulk/destroy' => 'alternate_content_sources_bulk_actions#destroy_alternate_content_sources', :via => :put
            match '/bulk/refresh' => 'alternate_content_sources_bulk_actions#refresh_alternate_content_sources', :via => :post
            get :auto_complete_search
          end

          member do
            post :refresh
          end
        end

        api_resources :organizations do
          api_resources :sync_plans do
            member do
              put :add_products
              put :remove_products
              put :sync
            end
            collection do
              get :auto_complete_search
              match ':sync_plan_id/products', :to => 'products#index', :via => :get
            end
          end

          api_resources :content_views, :only => [:index, :create]
          api_resources :subscriptions, :only => [:index, :upload, :delete_manifest, :refresh_manifest, :show] do
            collection do
              post :upload
              post :delete_manifest
              put :refresh_manifest
            end
          end

          api_resources :simple_content_access, only: [] do
            collection do
              put :enable
              put :disable
              get :eligible
              get :status
            end
          end

          api_resources :upstream_subscriptions, only: [:index, :create] do
            collection do
              delete :destroy
              put :update
              get :ping
              match '/simple_content_access/enable', :to => 'upstream_subscriptions#enable_simple_content_access', :via => :put
              match '/simple_content_access/disable', :to => 'upstream_subscriptions#disable_simple_content_access', :via => :put
              match '/simple_content_access/eligible', :to => 'upstream_subscriptions#simple_content_access_eligible', :via => :get
              match '/simple_content_access/status', :to => 'upstream_subscriptions#simple_content_access_status', :via => :get
            end
          end
        end

        api_resources :host_collections

        api_resources :repositories, :only => [], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
          collection do
            match '/bulk/destroy' => 'repositories_bulk_actions#destroy_repositories', :via => :put
            match '/bulk/sync' => 'repositories_bulk_actions#sync_repositories', :via => :post
            match '/bulk/reclaim_space' => 'repositories_bulk_actions#reclaim_space_from_repositories', :via => :post
            get :auto_complete_search
          end
          api_resources :sync, :only => [:index]

          api_resources :packages, :only => [:index, :show]
          api_resources :package_groups, :only => [:index, :show]
          api_resources :files, :only => [:index, :show], :controller => 'file_units'
          api_resources :errata, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z\-+%_.:]+/}
          api_resources :docker_manifests, :only => [:index, :show]
          api_resources :docker_manifest_lists, :only => [:index, :show]
          api_resources :docker_tags, :only => [:index, :show]
          api_resources :debs, :only => [:index, :show]
          api_resources :module_streams, :only => [:index, :show]
          api_resources :ansible_collections, :only => [:index, :show]
          Katello::RepositoryTypeManager.generic_content_types(false).each do |type|
            api_resources type.pluralize.to_sym, :only => [:index, :show], :controller => 'generic_content_units', :content_type => type
          end
          api_resources :content_units, :only => [:index, :show], :controller => 'generic_content_units'

          api_resources :content_uploads, :controller => :content_uploads, :only => [:create, :destroy, :update]

          member do
            get :gpg_key_content
            put :remove_packages, :action => :remove_content
            put :remove_docker_manifests, :action => :remove_content
            put :remove_content
            post :sync
            post :verify_checksum
            post :reclaim_space
            post :upload_content
            put :import_uploads
          end
        end

        api_resources :environments, :only => [] do
          api_resources :products, :only => [:index] do
            api_resources :repositories, :only => [:index] do
              get :index, :on => :member
            end
          end

          api_resources :content_views, :only => [:index]

          member do
            get :repositories
          end
        end

        api_resources :products, :only => [] do
          api_resources :repositories, :only => [:index] do
            get :index, :on => :member
          end
          api_resources :sync, :only => [:index]

          collection do
            match '/bulk/destroy' => 'products_bulk_actions#destroy_products', :via => :put
            match '/bulk/sync' => 'products_bulk_actions#sync_products', :via => :put
            match '/bulk/verify_checksum' => 'products_bulk_actions#verify_checksum_products', :via => :put
            match '/bulk/sync_plan' => 'products_bulk_actions#update_sync_plans', :via => :put
            match '/bulk/http_proxy' => 'products_bulk_actions#update_http_proxy', :via => :put
          end
        end

        api_resources :subscriptions, :only => [] do
          api_resources :products, :only => [:index]
        end

        api_resources :sync_plans, :only => [:index, :show, :update, :destroy] do
          api_resources :products, :only => [:index]
          get :auto_complete_search, :on => :collection
          put :sync
        end
      end # module v2
    end # '/api' namespace
  end # '/katello' namespace
end
