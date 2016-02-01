require 'katello/api/constraints/activation_key_constraint'
require 'katello/api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Katello::Engine.routes.draw do
  scope :katello, :path => '/katello' do
    namespace :api do
      scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v2/, :constraints => ApiConstraints.new(:version => 2, :default => true) do
        ##############################
        # re-routes alphabetical
        ##############################

        root :to => 'root#resource_list'

        api_resources :capsules, :only => [:index, :show] do
          member do
            resource :content, :only => [], :controller => 'capsule_content' do
              get :lifecycle_environments
              get :available_lifecycle_environments
              post :sync
              post '/lifecycle_environments' => 'capsule_content#add_lifecycle_environment'
              delete '/lifecycle_environments/:environment_id' => 'capsule_content#remove_lifecycle_environment'
            end
          end
        end

        api_resources :activation_keys, :only => [:index, :create, :show, :update, :destroy] do
          get :auto_complete_search, :on => :collection
          member do
            match '/product_content' => 'activation_keys#product_content', :via => :get
            match '/content_override' => 'activation_keys#content_override', :via => :put
            post :copy
            put :add_subscriptions
            put :remove_subscriptions
            get :subscriptions
          end
          match '/releases' => 'activation_keys#available_releases', :via => :get, :on => :member
          api_resources :host_collections, :only => [:index]
          member do
            match '/host_collections' => 'activation_keys#add_host_collections', :via => :post
            match '/host_collections' => 'activation_keys#remove_host_collections', :via => :put
            match '/host_collections/available' => 'activation_keys#available_host_collections', :via => :get
          end
          api_resources :products, :only => [:index]
          api_resources :subscriptions, :only => [] do
            collection do
              match '/available' => 'subscriptions#available', :via => :get
            end
          end
          api_resources :systems, :only => [:index]
        end

        api_resources :content_views do
          get :auto_complete_search, :on => :collection
          member do
            post :copy
            post :publish
            post :refresh
            put :remove
            get :available_puppet_modules
            get :available_puppet_module_names
            match '/environments/:environment_id' => "content_views#remove_from_environment", :via => :delete
          end
          api_resources :content_view_puppet_modules do
            collection do
              get :auto_complete_search
            end
          end
          api_resources :filters, :controller => :content_view_filters do
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
          api_resources :puppet_modules, :only => [:index]
          api_resources :repositories, :only => [:index]
          api_resources :content_view_versions, :only => [:index]
        end

        api_resources :content_view_filters do
          api_resources :errata, :only => [:index]
          api_resources :package_groups, :only => [:index]
          api_resources :rules, :controller => :content_view_filter_rules
          collection do
            get :auto_complete_search
          end
        end

        api_resources :content_view_versions, :except => [:create] do
          member do
            post :promote
          end
          collection do
            get :auto_complete_search
            post :incremental_update
          end
        end

        api_resources :docker_images, :only => [:index, :show]
        api_resources :docker_tags, :only => [:index, :show] do
          collection do
            get :auto_complete_search
          end
        end
        api_resources :grouped_docker_tags, :only => [:index, :show]

        api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
          api_resources :activation_keys, :only => [:index, :create]
          api_resources :puppet_modules, :only => [:index]
          api_resources :systems, :only => [:index, :show, :create, :update, :destroy] do
            get :report, :on => :collection
          end
        end

        api_resources :errata, :only => [:index, :show] do
          collection do
            get :compare
            get :auto_complete_search
          end
        end

        api_resources :gpg_keys, :only => [:index, :show, :create, :update, :destroy] do
          post :content, :on => :member
          get :auto_complete_search, :on => :collection
        end

        api_resources :host_collections, :only => [:index, :show, :create, :update, :destroy] do
          member do
            post :copy
            put :add_hosts
            put :remove_hosts
          end
          get :auto_complete_search, :on => :collection
        end

        api_resources :organizations, :only => [:index, :show, :update, :create, :destroy] do
          api_resources :activation_keys, :only => [:index]
          api_resources :content_views, :only => [:index, :create]
          api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
            collection do
              get :paths
              get :auto_complete_search
            end
          end
          api_resources :host_collections, :only => [:index, :create]
          member do
            get :manifest_history
            post :repo_discover
            post :cancel_repo_discover
            post :autoattach_subscriptions
            get :download_debug_certificate
            get :redhat_provider
          end
          api_resources :products, :only => [:index]
          api_resources :subscriptions, :only => [:index] do
            collection do
              match '/available' => 'subscriptions#available', :via => :get
              get :auto_complete_search
              get :manifest_history
            end
          end
          api_resources :systems, :only => [:index, :show, :create, :update, :destroy] do
            get :report, :on => :collection
          end
        end

        api_resources :packages, :only => [:index, :show] do
          collection do
            get :auto_complete_search
            get :auto_complete_name
          end
        end

        api_resources :package_groups, :only => [:index, :show] do
          collection do
            get :auto_complete_search
          end
        end

        api_resources :ping, :only => [:index]
        match "/status" => "ping#server_status", :via => :get

        api_resources :products, :only => [:index, :show, :create, :update, :destroy] do
          member do
            post :sync
          end
          collection do
            get :auto_complete_search
          end
          api_resources :repository_sets, :only => [:index, :show] do
            member do
              get :available_repositories
              put :enable
              put :disable
            end
          end
        end
        api_resources :puppet_modules, :only => [:index, :show] do
          get :auto_complete_search, :on => :collection
        end

        api_resources :repositories, :only => [:index, :create, :show, :destroy, :update] do
          collection do
            post :sync_complete
            get :auto_complete_search
            get :repository_types
          end
        end

        api_resources :repository_sets, :only => [:index, :show] do
          member do
            put :enable
            put :disable
          end
        end

        api_resources :subscriptions, :only => [:index, :show] do
          collection do
            get :auto_complete_search
          end
        end

        api_resources :systems, :only => [:index, :show, :create, :update, :destroy] do
          member do
            post :host_collections, :action => :add_host_collections
            delete :host_collections, :action => :remove_host_collections
            get :pools
            get :releases
            put :content_override
            get :product_content
            post :subscriptions, :action => :add_subscriptions
          end
          collection do
            get :auto_complete_search
          end
          api_resources :activation_keys, :only => [:index]
          api_resources :host_collections, :only => [:index]
          api_resources :products, :only => [:index]
        end

        ##############################
        ##############################

        api_resources :organizations do
          api_resources :sync_plans do
            member do
              put :add_products
              put :remove_products
              put :sync
            end
            collection do
              get :auto_complete_search
              match ':sync_plan_id/available_products', :to => 'products#index',
                :available_for => 'sync_plan', :via => :get
              match ':sync_plan_id/products', :to => 'products#index', :via => :get
            end
          end
          api_resources :systems, :only => [:create] do
            get :report, :on => :collection
          end

          resource :uebercert, :only => [:show]

          api_resources :gpg_keys, :only => [:index]

          api_resources :content_views, :only => [:index, :create]
          api_resources :subscriptions, :only => [:index, :upload, :delete_manifest, :refresh_manifest, :show] do
            collection do
              post :upload
              post :delete_manifest
              put :refresh_manifest
            end
          end
        end

        api_resources :host_collections do
          member do
            delete :destroy_hosts
          end
        end

        api_resources :systems, :only => [] do
          member do
            get :events
          end
          collection do
            match '/post_index' => 'systems#index', :via => :post
            match '/bulk/add_host_collections' => 'systems_bulk_actions#bulk_add_host_collections', :via => :put
            match '/bulk/remove_host_collections' => 'systems_bulk_actions#bulk_remove_host_collections', :via => :put
            match '/bulk/install_content' => 'systems_bulk_actions#install_content', :via => :put
            match '/bulk/applicable_errata' => 'systems_bulk_actions#applicable_errata', :via => :post
            match '/bulk/update_content' => 'systems_bulk_actions#update_content', :via => :put
            match '/bulk/remove_content' => 'systems_bulk_actions#remove_content', :via => :put
            match '/bulk/destroy' => 'systems_bulk_actions#destroy_systems', :via => :put
            match '/bulk/environment_content_view' => 'systems_bulk_actions#environment_content_view', :via => :put
            match '/bulk/available_incremental_updates' => 'systems_bulk_actions#available_incremental_updates', :via => :post
            get :auto_complete_search
          end

          api_resources :errata, :only => [:show, :index], :controller => :system_errata do
            collection do
              put :apply
              get :auto_complete_search
            end
          end
        end

        api_resources :repositories, :only => [], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
          collection do
            match '/bulk/destroy' => 'repositories_bulk_actions#destroy_repositories', :via => :put
            match '/bulk/sync' => 'repositories_bulk_actions#sync_repositories', :via => :post
            get :auto_complete_search
          end
          api_resources :sync, :only => [:index] do
            delete :index, :on => :collection, :action => :cancel
          end

          api_resources :export, :only => [:index]

          api_resources :packages, :only => [:index, :show] do
            get :search, :on => :collection
          end
          api_resources :package_groups, :only => [:index, :show]
          api_resources :errata, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z\-\+%_.:]+/}
          api_resources :distributions, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z \-\+%_.]+/}
          api_resources :puppet_modules, :only => [:index, :show] do
            get :search, :on => :collection
          end
          api_resources :docker_images, :only => [:index, :show]
          api_resources :docker_tags, :only => [:index, :show]

          api_resources :content_uploads, :controller => :content_uploads, :only => [:create, :destroy, :update]

          member do
            get :package_groups
            get :package_group_categories
            get :gpg_key_content
            put :remove_packages, :action => :remove_content
            put :remove_puppet_modules, :action => :remove_content
            put :remove_docker_images, :action => :remove_content
            put :remove_content
            post :sync
            post :export
            post :upload_content
            put :import_uploads
          end
        end

        api_resources :environments, :only => [] do
          api_resources :products, :only => [:index] do
            get :repositories, :on => :member
          end

          api_resources :content_views, :only => [:index]

          member do
            get :releases
            get :repositories
          end
        end

        api_resources :products, :only => [] do
          get :repositories, :on => :member
          api_resources :sync, :only => [:index] do
            delete :index, :on => :collection, :action => :cancel
          end

          collection do
            match '/bulk/destroy' => 'products_bulk_actions#destroy_products', :via => :put
            match '/bulk/sync' => 'products_bulk_actions#sync_products', :via => :put
            match '/bulk/sync_plan' => 'products_bulk_actions#update_sync_plans', :via => :put
          end
        end

        api_resources :subscriptions, :only => [] do
          api_resources :products, :only => [:index]
        end

        api_resources :users do
          get :report, :on => :collection
        end

        api_resources :sync_plans, :only => [:index, :show, :update, :destroy] do
          get :auto_complete_search, :on => :collection
          put :sync
        end
      end # module v2
    end # '/api' namespace
  end # '/katello' namespace
end
