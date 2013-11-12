require 'api/constraints/activation_key_constraint'
require 'api/constraints/api_version_constraint'
require 'api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Src::Application.routes.draw do

  namespace :api do

    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiVersionConstraint.new(:version => 2) do

      match '/' => 'root#resource_list'

      # Headpin does not support system creation
      if Katello.config.katello?
        onlies = [:show, :destroy, :create, :index, :update]
      else
        onlies = [:show, :destroy, :index, :update]
      end

      api_resources :organizations do
        member do
          post :repo_discover
          post :cancel_repo_discover
        end
        api_resources :products, :only => [:index]
        api_resources :environments
        api_resources :sync_plans, :only => [:index, :create]
        api_resources :tasks, :only => [:index, :show]
        api_resources :providers, :only => [:index], :constraints => {:organization_id => /[^\/]*/}
        scope :constraints => RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
        api_resources :systems, :only => [:index, :create] do
          get :report, :on => :collection
        end
        api_resources :distributors, :only => [:index, :create]
        resource :uebercert, :only => [:show]

        api_resources :activation_keys, :only => [:index, :create]
        api_resources :system_groups, :only => [:index, :create]
        api_resources :gpg_keys, :only => [:index, :create]

        match '/default_info/:informable_type' => 'organization_default_info#create', :via => :post, :as => :create_default_info
        match '/default_info/:informable_type/*keyname' => 'organization_default_info#destroy', :via => :delete, :as => :destroy_default_info
        match '/default_info/:informable_type/apply' => 'organization_default_info#apply_to_all', :via => :post, :as => :apply_default_info

        match '/auto_attach' => 'organizations#auto_attach_all_systems', :via => :post, :as => :auto_attach_all_systems

        api_resources :content_views, :only => [:index, :create]
        api_resources :content_view_definitions, :only => [:index, :create]
      end

      api_resources :system_groups do
        member do
          get :systems
          get :history
          match "/history/:job_id" => "system_groups#history_show", :via => :get
          post :add_systems
          post :copy
          post :remove_systems
          delete :destroy_systems
        end

        resource :packages, :action => [:create, :update, :destroy], :controller => :system_group_packages
        api_resources :errata, :only => [:index, :create], :controller => :system_group_errata
      end

      api_resources :systems, :only => onlies do
        member do
          get :packages, :action => :package_profile
          get :errata
          get :pools
          get :releases
          get :tasks
          put :enabled_repos
          post :system_groups, :action => :add_system_groups
          delete :system_groups, :action => :remove_system_groups
          put :refresh_subscriptions
        end
        collection do
          match "/tasks/:task_id" => "systems#task", :via => :get
          match '/add_system_groups' => 'systems_bulk_actions#bulk_add_system_groups', :via => :put
          match '/remove_system_groups' => 'systems_bulk_actions#bulk_remove_system_groups', :via => :put
          match '/install_content' => 'systems_bulk_actions#install_content', :via => :put
          match '/update_content' => 'systems_bulk_actions#update_content', :via => :put
          match '/remove_content' => 'systems_bulk_actions#remove_content', :via => :put
          match '/destroy' => 'systems_bulk_actions#destroy_systems', :via => :put
        end
        api_resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy_all', :via => :delete
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
            match '/available' => 'subscriptions#available', :via => :get
          end
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

      api_resources :subscriptions, :only => [] do
        collection do
          get :index, :action => :organization_index
        end
      end

      api_resources :providers do
        api_resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        member do
          post :import_manifest
          post :delete_manifest
          put :refresh_products
          post :product_create
          get :products
          post :discovery
        end
      end

      api_resources :content_view_definitions, :only => [:update, :show, :destroy] do
        member do
          post :publish
          post :clone
        end
        resources :products, :controller => :content_view_definitions, :only => [] do
          collection do
            get :index, :action => :list_products
            put :index, :action => :update_products
            get :all, :action => :list_all_products
          end
        end
        resources :repositories, :controller => :content_view_definitions, :only => [] do
          collection do
            get :index, :action => :list_repositories
            put :index, :action => :update_repositories
          end
        end
        get :content_views
        put :content_views, :action => :update_content_views
        resources :filters, :controller => :filters, :only => [:index, :show, :create, :destroy] do
          resources :products, :controller => :filters, :only => [] do
            collection do
              get :index, :action => :list_products
              put :index, :action => :update_products
            end
          end
          resources :repositories, :controller => :filters, :only => [] do
            collection do
              get :index, :action => :list_repositories
              put :index, :action => :update_repositories
            end
          end
          resources :rules, :controller => :filter_rules, :only => [:create, :destroy]
        end
      end

      api_resources :content_views, :only => [:update, :show] do
        member do
          post :promote
          post :refresh
        end
      end

      api_resources :changesets, :only => [:show, :update, :destroy] do
        post :apply, :on => :member, :action => :apply
        #TODO: fix dependency resolution
        #get :dependencies, :on => :member, :action => :dependencies

        api_attachable_resources :products, :controller => :changesets_content
        api_attachable_resources :packages, :controller => :changesets_content, :constraints => {:id => /[0-9a-zA-Z\-_.]+/}
        api_attachable_resources :errata, :controller => :changesets_content
        api_attachable_resources :repositories, :controller => :changesets_content, :resource_name => :repo
        api_attachable_resources :distributions, :controller => :changesets_content
        api_attachable_resources :templates, :controller => :changesets_content
        api_attachable_resources :content_views, :controller => :changesets_content
      end

      api_resources :ping, :only => [:index]

      api_resources :repositories, :only => [:index, :create, :show, :update, :destroy], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
        api_resources :sync, :only => [:index] do
          delete :index, :on => :collection, :action => :cancel
        end

        api_resources :packages, :only => [:index, :show] do
          get :search, :on => :collection
        end
        api_resources :errata, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z\-\+%_.:]+/}
        api_resources :distributions, :only => [:index, :show], :constraints => {:id => /[0-9a-zA-Z \-\+%_.]+/}
        api_resources :puppet_modules, :only => [:index, :show] do
          get :search, :on => :collection
        end
        member do
          get :package_groups
          get :package_group_categories
          get :gpg_key_content
          post :sync
        end
        collection do
          post :sync_complete
        end
      end

      api_resources :environments, :only => [:show, :update, :destroy] do
        scope :constraints => RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
        api_resources :systems, :only => [:create, :index] do
          get :report, :on => :collection
        end
        api_resources :distributors, :only => [:create, :index]
        api_resources :products, :only => [:index] do
          get :repositories, :on => :member
        end

        api_resources :activation_keys, :only => [:index, :create]
        api_resources :content_views, :only => [:index]
        api_resources :changesets, :only => [:index, :create]

        member do
          get :releases
          get :repositories
        end
      end

      api_resources :gpg_keys, :only => [:index, :show, :update, :destroy] do
        get :content, :on => :member
      end

      api_resources :activation_keys, :only => [:destroy, :show, :update] do
        member do
          api_attachable_resources :system_groups, :controller => :activation_keys, :resource_name => :system_groups
          api_attachable_resources :pools, :controller => :activation_keys
        end
      end

      api_resources :products, :only => [:index, :show, :update, :destroy, :create] do
        post :sync_plan, :on => :member, :action => :set_sync_plan
        delete :sync_plan, :on => :member, :action => :remove_sync_plan
        api_resources :repositories, :only => [:create, :index]
        get :repositories, :on => :member
        api_resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        api_resources :repository_sets, :only => [:index] do
          put :enable, :on => :member
          put :disable, :on => :member
        end
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
      api_resources :tasks, :only => [:show] do
        post :search, :on => :collection
      end
      api_resources :about, :only => [:index]

      match "/version" => "ping#version", :via => :get
      match "/status" => "ping#server_status", :via => :get

      # api custom information
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#create', :via => :post, :as => :create_custom_info
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#index', :via => :get, :as => :custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#show', :via => :get, :as => :show_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#update', :via => :put, :as => :update_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#destroy', :via => :delete, :as => :destroy_custom_info

      # subscription-manager support
      match '/users/:username/owners' => 'users#list_owners', :via => :get

    end # module v2

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiVersionConstraint.new(:version => 2) do

      api_resources :crls, :only => [:index]

      # subscription-manager support
      scope :constraints => RegisterWithActivationKeyContraint.new do
        match '/consumers' => 'systems#activate', :via => :post
      end
      match '/hypervisors' => 'systems#hypervisors_update', :via => :post
      api_resources :consumers, :controller => 'systems'
      match '/owners/:organization_id/environments' => 'environments#rhsm_index', :via => :get
      match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_pools_path
      match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_servicelevels_path
      match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
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

    end # module v1

  end # '/api' namespace

end
