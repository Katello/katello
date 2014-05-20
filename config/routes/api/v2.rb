require 'katello/api/constraints/activation_key_constraint'
require 'katello/api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Katello::Engine.routes.draw do

  namespace :api do

    scope "(:api_version)", :module => :v2, :defaults => {:api_version => 'v2'}, :api_version => /v1|v2/, :constraints => ApiConstraints.new(:version => 2) do

      ##############################
      # re-routes alphabetical
      ##############################

      # we don't want headpin to be able to create system directly
      system_onlies = Katello.config.katello? ? [:index, :show, :destroy, :create, :update] : [:index, :show, :destroy, :update]

      root :to => 'root#resource_list'

      api_resources :activation_keys, :only => [:index, :create, :show, :update, :destroy] do
        member do
          match '/content_override' => 'activation_keys#content_override', :via => :put
        end
        match '/releases' => 'activation_keys#available_releases', :via => :get, :on => :member
        api_resources :host_collections, :only => [:index]
        member do
          match '/host_collections' => 'activation_keys#add_host_collections', :via => :post
          match '/host_collections' => 'activation_keys#remove_host_collections', :via => :put
          match '/host_collections/available' => 'activation_keys#available_host_collections', :via => :get
        end
        api_resources :products, :only => [:index]
        api_resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy', :via => :put
            match '/available' => 'subscriptions#available', :via => :get
          end
        end
      end

      api_resources :content_views do
        member do
          post :publish
          post :refresh
          put :remove
          get :history
          get :available_puppet_modules
          get :available_puppet_module_names
          match '/environments/:environment_id' => "content_views#remove_from_environment", :via => :delete
        end
        api_resources :content_view_puppet_modules
        api_resources :filters, :controller => :content_view_filters do
          member do
            get :available_errata
            get :available_package_groups
          end
          api_resources :errata, :only => [:index]
          api_resources :package_groups, :only => [:index]
        end
        api_resources :puppet_modules, :only => [:index]
        api_resources :repositories, :only => [:index]
        api_resources :content_view_versions, :only => [:index]
      end

      api_resources :content_view_filters do
        api_resources :errata, :only => [:index]
        api_resources :package_groups, :only => [:index]
        api_resources :rules, :controller => :content_view_filter_rules
        member do
          get :available_errata
          get :available_package_groups
        end
      end

      api_resources :content_view_versions, :except => [:create] do
        member do
          post :promote
        end
      end

      api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
        api_resources :activation_keys, :only => [:index, :create]
        api_resources :puppet_modules, :only => [:index]
        api_resources :systems, :only => system_onlies do
          get :report, :on => :collection
        end
        scope :constraints => Katello::RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
      end

      api_resources :errata, :only => [:index, :show]

      api_resources :gpg_keys, :only => [:index, :show, :create, :update, :destroy] do
        post :content, :on => :member
      end

      api_resources :host_collections, :only => system_onlies do
        member do
          post :copy
          put :add_systems
          put :remove_systems
          put :add_activation_keys
          put :remove_activation_keys
        end
        api_resources :systems, :only => system_onlies
      end

      api_resources :organizations, :only => [:index, :show, :update, :create, :destroy] do
        api_resources :activation_keys, :only => [:index]
        api_resources :content_views, :only => [:index, :create]
        api_resources :environments, :only => [:index, :show, :create, :update, :destroy] do
          collection do
            get :paths
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
            get :manifest_history
          end
        end
        api_resources :systems, :only => system_onlies do
          get :report, :on => :collection
        end
        scope :constraints => Katello::RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
      end

      api_resources :package_groups, :only => [:index, :show]

      api_resources :ping, :only => [:index]
      match "/status" => "ping#server_status", :via => :get

      api_resources :products, :only => [:index, :show, :create, :update, :destroy] do
        member do
          post :sync
        end
        api_resources :repository_sets, :only => [:index, :show] do
          member do
            get :available_repositories
            put :enable
            put :disable
          end
        end
      end
      api_resources :puppet_modules, :only => [:index, :show]

      api_resources :repositories, :only => [:index, :create, :show, :destroy, :update] do
        collection do
          post :sync_complete
        end
      end

      api_resources :repository_sets, :only => [:index, :show] do
        member do
          put :enable
          put :disable
        end
      end

      api_resources :subscriptions, :only => [:show]

      api_resources :systems, :only => system_onlies do
        member do
          get :tasks
          match '/tasks/:id' => 'tasks#show', :via => :get
          get :available_host_collections, :action => :available_host_collections
          post :host_collections, :action => :add_host_collections
          delete :host_collections, :action => :remove_host_collections
          get :packages, :action => :package_profile
          get :errata
          get :pools
          get :releases
          put :refresh_subscriptions
        end
        api_resources :activation_keys, :only => [:index]
        api_resources :host_collections, :only => [:index]
        api_resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy', :via => :put
            match '/available' => 'subscriptions#available', :via => :get
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
          end
        end
      end

      ##############################
      ##############################

      api_resources :organizations do
        api_resources :sync_plans do
          member do
            get :available_products
            put :add_products
            put :remove_products
          end
        end
        api_resources :tasks, :only => [:index, :show]
        scope :constraints => Katello::RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
        api_resources :systems, :only => [:create] do
          get :report, :on => :collection
        end

        api_resources :distributors, :only => [:index, :create]
        resource :uebercert, :only => [:show]

        api_resources :gpg_keys, :only => [:index]

        match '/default_info/:informable_type' => 'organization_default_info#create', :via => :post, :as => :create_default_info
        match '/default_info/:informable_type/*keyname' => 'organization_default_info#destroy', :via => :delete, :as => :destroy_default_info
        match '/default_info/:informable_type/apply' => 'organization_default_info#apply_to_all', :via => :post, :as => :apply_default_info

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
          get :history
          match "/history/:job_id" => "host_collections#history_show", :via => :get
          delete :destroy_systems
        end

        resource :packages, :action => [:create, :update, :destroy], :controller => :host_collection_packages
        api_resources :errata, :only => [:index, :create], :controller => :host_collection_errata
      end

      api_resources :systems, :only => [] do
        collection do
          match '/bulk/add_host_collections' => 'systems_bulk_actions#bulk_add_host_collections', :via => :put
          match '/bulk/remove_host_collections' => 'systems_bulk_actions#bulk_remove_host_collections', :via => :put
          match '/bulk/install_content' => 'systems_bulk_actions#install_content', :via => :put
          match '/bulk/applicable_errata' => 'systems_bulk_actions#applicable_errata', :via => :post
          match '/bulk/update_content' => 'systems_bulk_actions#update_content', :via => :put
          match '/bulk/remove_content' => 'systems_bulk_actions#remove_content', :via => :put
          match '/bulk/destroy' => 'systems_bulk_actions#destroy_systems', :via => :put
          match '/bulk/environment_content_view' => 'systems_bulk_actions#environment_content_view', :via => :put
        end
        resource :packages, :only => [], :controller => :system_packages do
          collection do
            put :remove
            put :install
            put :upgrade
            put :upgrade_all
          end
        end
        api_resources :errata, :only => [:show], :controller => :system_errata do
          collection do
            put :apply
          end
        end

      end

      api_resources :distributors, :only => [:show, :destroy, :create, :index, :update] do
        member do
          get :pools
        end
        api_resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy_all', :via => :delete
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
          end
        end
      end
      match "/distributor_versions" => "distributors#versions", :via => :get, :as => :distributor_versions

      api_resources :repositories, :only => [], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
        collection do
          match '/bulk/destroy' => 'repositories_bulk_actions#destroy_repositories', :via => :put
          match '/bulk/sync' => 'repositories_bulk_actions#sync_repositories', :via => :post
        end
        api_resources :sync, :only => [:index] do
          delete :index, :on => :collection, :action => :cancel
        end

        api_resources :packages, :only => [:index, :show] do
          get :search, :on => :collection
        end
        api_resources :package_groups, :only => [:index, :show]
        api_resources :errata, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z\-\+%_.:]+/}
        api_resources :distributions, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z \-\+%_.]+/}
        api_resources :puppet_modules, :only => [:index, :show] do
          get :search, :on => :collection
        end

        api_resources :content_uploads, :controller => :content_uploads, :only => [:create, :destroy] do
          member do
            put :upload_bits
          end
          collection do
            post :file, :to => 'content_uploads#upload_file'
            post :import_into_repo
          end
        end
        member do
          get :package_groups
          get :package_group_categories
          get :gpg_key_content
          post :sync
        end
      end

      api_resources :environments, :only => [] do
        api_resources :distributors, :only => [:create, :index]
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
        get :sync_ldap_roles, :on => :collection
        api_resources :roles, :controller => :users, :only => [] do
          post :index, :on => :collection, :action => :add_role
          delete :destroy, :on => :member, :action => :remove_role
          get :index, :on => :collection, :action => :list_roles
        end
      end

      api_resources :roles do
        get :available_verbs, :on => :collection, :action => :available_verbs
        api_resources :permissions, :only => [:index, :show, :create, :destroy]
        api_resources :ldap_groups, :controller => :role_ldap_groups, :only => [:create, :destroy, :index]
      end

      api_resources :sync_plans, :only => [:show, :update, :destroy]
      api_resources :tasks, :only => [:show]
      api_resources :about, :only => [:index]

      # api custom information
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#create', :via => :post, :as => :create_custom_info
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#index', :via => :get, :as => :custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#show', :via => :get, :as => :show_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#update', :via => :put, :as => :update_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#destroy', :via => :delete, :as => :destroy_custom_info

      # subscription-manager support
      match '/users/:login/owners' => 'users#list_owners', :via => :get

    end # module v2

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiConstraints.new(:version => 2) do

      api_resources :crls, :only => [:index]

      # subscription-manager support
      scope :constraints => Katello::RegisterWithActivationKeyContraint.new do
        match '/consumers' => 'systems#activate', :via => :post
      end
      match '/hypervisors' => 'systems#hypervisors_update', :via => :post
      api_resources :consumers, :controller => 'systems'
      match '/owners/:organization_id/environments' => 'environments#rhsm_index', :via => :get
      match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_pools_path
      match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_servicelevels_path
      match '/environments/:environment_id/consumers' => 'systems#index', :via => :get #TODO: does this need to stay or be moved over to v2 controller also (e.g. - systems#index_v1_compat)?
      match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
      match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
      match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_certificates_path
      match '/consumers/:id/release' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_releases_path
      match '/consumers/:id/certificates/serials' => 'candlepin_proxies#get', :via => :get, :as => :proxy_certificate_serials_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_entitlements_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post, :as => :proxy_consumer_entitlements_post_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_entitlements_delete_path
      match '/consumers/:id/entitlements/dry-run' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_dryrun_path
      match '/consumers/:id/owner' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_owners_path
      match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_certificates_delete_path
      match '/consumers/:id/deletionrecord' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_deletionrecord_delete_path
      match '/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_pools_path
      match '/deleted_consumers' => 'candlepin_proxies#get', :via => :get, :as => :proxy_deleted_consumers_path
      match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get, :as => :proxy_entitlements_path
      match '/subscriptions' => 'candlepin_proxies#post', :via => :post, :as => :proxy_subscriptions_post_path
      match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put
      match '/consumers/:id/packages/' => 'systems#upload_package_profile', :via => :put

      # development / debugging support
      if Rails.env == "development"
        match 'status/memory' => 'status#memory', :via => :get
      end

    end # module v2

  end # '/api' namespace
end
