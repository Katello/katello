require 'api/constraints/activation_key_constraint'
require 'api/constraints/api_version_constraint'

Src::Application.routes.draw do

  namespace :api do

    scope :module => :v1, :constraints => ApiVersionConstraint.new(:version => 1, :default => true) do

      match '/' => 'root#resource_list'

      # Headpin does not support system creation
      if Katello.config.katello?
        onlies = [:show, :destroy, :create, :index, :update]
      else
        onlies = [:show, :destroy, :index, :update]
      end

      resources :organizations do
        resources :products, :only => [:index, :show, :update, :destroy] do
          get :repositories, :on => :member
          post :sync_plan, :on => :member, :action => :set_sync_plan
          delete :sync_plan, :on => :member, :action => :remove_sync_plan
          get :repositories, :on => :member
          resources :sync, :only => [:index, :create] do
            delete :index, :on => :collection, :action => :cancel
          end
          resources :repository_sets, :only => [:index] do
            post :enable, :on => :member
            post :disable, :on => :member
          end
        end

        resources :system_groups, :except => [:new, :edit] do
          member do
            get :systems
            get :history
            match "/history/:job_id" => "system_groups#history_show", :via => :get
            post :add_systems
            post :copy
            post :remove_systems
            delete :destroy_systems
            put :update_systems
          end

          resource :packages, :action => [:create, :update, :destroy], :controller => :system_group_packages
          resources :errata, :only => [:index, :create], :controller => :system_group_errata
        end

        resources :environments do
          get :repositories, :on => :member
          resources :changesets, :only => [:index, :create]
        end
        resources :sync_plans
        resources :tasks, :only => [:index]
        resources :providers, :only => [:index], :constraints => { :organization_id => /[^\/]*/ }

        scope :constraints => RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
        resources :systems, :only => [:index, :create] do
          get :report, :on => :collection

          collection do
            get :tasks
          end
        end
        resources :distributors, :only => [:index, :create]
        resources :activation_keys, :only => [:index, :create, :destroy, :show, :update] do
          member do
            post :system_groups, :action => :add_system_groups
            delete :system_groups, :action => :remove_system_groups

            post :pools, :action => :add_pool
            delete "pools/:poolid", :action => :remove_pool
          end
        end
        resources :repositories, :only => [] do
        end
        resource :uebercert, :only => [:show]

        resources :gpg_keys, :only => [:index, :create]

        match '/default_info/:informable_type' => 'organization_default_info#create', :via => :post, :as => :create_default_info
        match '/default_info/:informable_type/:keyname' => 'organization_default_info#destroy', :via => :delete, :as => :destroy_default_info
        match '/default_info/:informable_type/apply' => 'organization_default_info#apply_to_all', :via => :post, :as => :apply_default_info

        match '/auto_attach' => 'organizations#auto_attach_all_systems', :via => :post, :as => :auto_attach_all_systems

        resources :content_views, :only => [:index, :show, :destroy]
        resources :content_view_definitions do
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
      end

      resources :systems, :only => onlies do
        member do
          get :packages, :action => :package_profile
          get :errata
          get :pools
          get :releases
          get :subscription_status
          put :enabled_repos
          post :system_groups, :action => :add_system_groups
          delete :system_groups, :action => :remove_system_groups
          post :refresh_subscriptions
          put :checkin
        end
        collection do
          match "/tasks/:id" => "tasks#show", :via => :get
        end
        resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy_all', :via => :delete
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
          end
        end
        resource :packages, :action => [:create, :update, :destroy], :controller => :system_packages
      end

      resources :distributors, :only => [:show, :destroy, :create, :index, :update] do
        member do
          get :pools
          get :export
        end
        resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
            match '/' => 'subscriptions#destroy_all', :via => :delete
            match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
          end
        end
      end

      resources :providers, :except => [:index] do
        resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        member do
          post :import_products
          post :import_manifest
          post :delete_manifest
          post :refresh_manifest
          post :refresh_products
          post :product_create
          get :products
          post :discovery
        end
      end

      resources :subscriptions, :only => [] do
        collection do
          get :index, :action => :organization_index
        end
      end

      resources :content_view_definitions, :only => [:destroy, :content_views] do
        get :content_views, :on => :member
        put :content_views, :on => :member, :action => :update_content_views
      end

      resources :content_views, :only => [:promote, :show] do
        member do
          post :promote
          post :refresh
        end
      end


      resources :changesets, :only => [:show, :update, :destroy] do
        post :promote, :on => :member, :action => :promote
        post :apply, :on => :member, :action => :apply
        get :dependencies, :on => :member, :action => :dependencies
        resources :products, :controller => :changesets_content do
          post :index, :on => :collection, :action => :add_product
          delete :destroy, :on => :member, :action => :remove_product
        end
        resources :packages, :controller => :changesets_content, :constraints => { :id => /[0-9a-zA-Z\-_.]+/ } do
          post :index, :on => :collection, :action => :add_package
          delete :destroy, :on => :member, :action => :remove_package
        end
        resources :errata, :controller => :changesets_content do
          post :index, :on => :collection, :action => :add_erratum
          delete :destroy, :on => :member, :action => :remove_erratum
        end
        resources :repositories, :controller => :changesets_content do
          post :index, :on => :collection, :action => :add_repo
          delete :destroy, :on => :member, :action => :remove_repo
        end
        resources :distributions, :controller => :changesets_content do
          post :index, :on => :collection, :action => :add_distribution
          delete :destroy, :on => :member, :action => :remove_distribution
        end
        resources :content_views, :controller => :changesets_content do
          post :index, :on => :collection, :action => :add_content_view
          delete :destroy, :on => :member, :action => :remove_content_view
        end

      end

      resources :ping, :only => [:index]

      resources :repositories, :only => [:show, :create, :update, :destroy], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
        resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        resources :packages do
          get :search, :on => :collection
        end
        resources :errata, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.:]+/ }
        resources :distributions, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z \-\+%_.]+/ }
        member do
          get :package_groups
          get :package_group_categories
          get :gpg_key_content
          post :enable
        end
        collection do
          post :sync_complete
        end
      end

      resources :environments, :only => [:show, :update, :destroy] do
        scope :constraints => RegisterWithActivationKeyContraint.new do
          match '/systems' => 'systems#activate', :via => :post
        end
        resources :systems, :only => [:create, :index] do
          get :report, :on => :collection
        end
        resources :distributors, :only => [:create, :index]
        resources :products, :only => [:index] do
          get :repositories, :on => :member
        end
        resources :activation_keys, :only => [:index, :create]

        member do
          get :releases
        end
      end

      resources :gpg_keys, :only => [:show, :update, :destroy] do
        get :content, :on => :member
      end

      resources :activation_keys do
        post :pools, :action => :add_pool, :on => :member
        delete "pools/:poolid", :action => :remove_pool, :on => :member
      end

      resources :errata, :only => [:index]

      resources :users do
        get :report, :on => :collection
        get :sync_ldap_roles, :on => :collection
        resources :roles, :controller => :users, :only => [] do
          post :index, :on => :collection, :action => :add_role
          delete :destroy, :on => :member, :action => :remove_role
          get :index, :on => :collection, :action => :list_roles
        end
      end

      resources :roles do
        get :available_verbs, :on => :collection, :action => :available_verbs
        resources :permissions, :only => [:index, :show, :create, :destroy]
        resources :ldap_groups, :controller => :role_ldap_groups, :only => [:create, :destroy, :index]
      end

      resources :tasks, :only => [:show]

      resources :crls, :only => [:index]

      resources :about, :only => [:index]


      match "/status" => "ping#server_status", :via => :get
      match "/version" => "ping#version", :via => :get

      # subscription-manager support
      scope :constraints => RegisterWithActivationKeyContraint.new do
        match '/consumers' => 'systems#activate', :via => :post
      end
      match '/hypervisors' => 'systems#hypervisors_update', :via => :post
      resources :consumers, :controller => 'systems'
      match '/owners/:organization_id/environments' => 'environments#rhsm_index', :via => :get
      match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_pools_path
      match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_servicelevels_path
      match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
      match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
      match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
      match '/users/:username/owners' => 'users#list_owners', :via => :get
      match '/consumers/:id/certificates' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_certificates_path
      match '/consumers/:id/release' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_releases_path
      match '/consumers/:id/compliance' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_compliance_path
      match '/consumers/:id/certificates/serials' => 'candlepin_proxies#get', :via => :get, :as => :proxy_certificate_serials_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_entitlements_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#post', :via => :post, :as => :proxy_consumer_entitlements_post_path
      match '/consumers/:id/entitlements' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_entitlements_delete_path
      match '/consumers/:id/entitlements/dry-run' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_dryrun_path
      match '/consumers/:id/owner' => 'candlepin_proxies#get', :via => :get, :as => :proxy_consumer_owners_path
      match '/consumers/:id/export' => 'candlepin_proxies#export', :via => :get, :as => :proxy_consumer_export_path
      match '/consumers/:consumer_id/certificates/:id' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_certificates_delete_path
      match '/consumers/:id/deletionrecord' => 'candlepin_proxies#delete', :via => :delete, :as => :proxy_consumer_deletionrecord_delete_path
      match '/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_pools_path
      match '/deleted_consumers' => 'candlepin_proxies#get', :via => :get, :as => :proxy_deleted_consumers_path
      match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get, :as => :proxy_entitlements_path
      match '/subscriptions' => 'candlepin_proxies#post', :via => :post, :as => :proxy_subscriptions_post_path
      match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put
      match '/consumers/:id/packages/' => 'systems#upload_package_profile', :via => :put
      match '/consumers/:id/checkin/' => 'systems#checkin', :via => :put

      # development / debugging support
      if Rails.env == "development"
        match 'status/memory' => 'status#memory', :via => :get
      end

      # api custom information
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#create', :via => :post, :as => :create_custom_info
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#index', :via => :get, :as => :custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#show', :via => :get, :as => :show_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#update', :via => :put, :as => :update_custom_info
      match '/custom_info/:informable_type/:informable_id/*keyname' => 'custom_info#destroy', :via => :delete, :as => :destroy_custom_info

    end # v1 scope

  end # '/api' namespace

end
