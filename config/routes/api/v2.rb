require 'api/constraints/activation_key_constraint'
require 'api/constraints/api_version_constraint'
require 'api/mapper_extensions'

class ActionDispatch::Routing::Mapper
  include Katello::Routing::MapperExtensions
end

Src::Application.routes.draw do

  namespace :api do

    # routes that didn't change in v2 and point to v1
    scope :module => :v1, :constraints => ApiVersionConstraint.new(:version => 2, :default => true) do

      match '/' => 'root#resource_list'

      # Headpin does not support system creation
      if Katello.config.katello?
        onlies = [:show, :destroy, :create, :index, :update]
      else
        onlies = [:show, :destroy, :index, :update]
      end

      api_resources :systems, :only => onlies do
        member do
          get :packages, :action => :package_profile
          get :errata
          get :pools
          get :releases
          put :enabled_repos
          post :system_groups, :action => :add_system_groups
          delete :system_groups, :action => :remove_system_groups
        end
        collection do
          match "/tasks/:id" => "systems#task_show", :via => :get
        end
        api_resources :subscriptions, :only => [:create, :index, :destroy] do
          collection do
              match '/' => 'subscriptions#destroy_all', :via => :delete
              match '/serials/:serial_id' => 'subscriptions#destroy_by_serial', :via => :delete
          end
        end
        resource :packages, :action => [:create, :update, :destroy], :controller => :system_packages
      end

      api_resources :providers, :except => [:index] do
        api_resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        member do
          post :import_products
          post :import_manifest
          post :delete_manifest
          post :refresh_products
          post :product_create
          get :products
          post :discovery
        end
      end

      api_resources :templates, :except => [:index] do
        post :import, :on => :collection
        get :export, :on => :member
        get :validate, :on => :member

        api_attachable_resources :products, :controller => :templates_content
        api_attachable_resources :packages, :controller => :templates_content, :constraints => { :id => /[0-9a-zA-Z\-_.]+/ }
        api_attachable_resources :parameters, :controller => :templates_content
        api_attachable_resources :package_groups, :controller => :templates_content
        api_attachable_resources :package_group_categories, :controller => :templates_content
        api_attachable_resources :distributions, :controller => :templates_content
        api_attachable_resources :repositories, :controller => :templates_content, :resource_name => :repo
      end

      api_resources :organizations do
        api_resources :products, :only => [:index, :show, :update, :destroy] do
          get :repositories, :on => :member
          post :sync_plan, :on => :member, :action => :set_sync_plan
          delete :sync_plan, :on => :member, :action => :remove_sync_plan
          get :repositories, :on => :member
          api_resources :sync, :only => [:index, :create] do
            delete :index, :on => :collection, :action => :cancel
          end
        end

        api_resources :system_groups, :except => [:new, :edit] do
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

        api_resources :environments do
          get :repositories, :on => :member
          api_resources :changesets, :only => [:index, :create]
        end
        api_resources :sync_plans
        api_resources :tasks, :only => [:index]
        api_resources :providers, :only => [:index]
        match '/systems' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
        api_resources :systems, :only => [:index, :create] do
          get :report, :on => :collection

          collection do
            get :tasks
          end
        end
        api_resources :activation_keys, :only => [:index, :create, :destroy, :show, :update] do
          member do
            post :system_groups, :action => :add_system_groups
            delete :system_groups, :action => :remove_system_groups

            post :pools, :action => :add_pool
            delete "pools/:poolid", :action => :remove_pool
          end
        end
        api_resources :repositories, :only => [] do
        end
        resource :uebercert, :only => [:show]

        api_resources :gpg_keys, :only => [:index, :create]

        api_resources :system_info_keys, :only => [:create, :index], :controller => :organization_system_info_keys do
          get :apply, :on => :collection, :action => :apply_to_all_systems
        end
        match '/system_info_keys/:keyname' => 'organization_system_info_keys#destroy', :via => :delete

        api_resources :content_views, :only => [:index, :show]
        api_resources :content_view_definitions do
          post :publish, :on => :member
          api_resources :products, :only => [] do
            get :index, :action => :list_content_view_definition_products,
              :on => :collection
            put :index, :action => :update_content_view_definition_products,
              :on => :collection
          end
          api_resources :repositories, :only => [] do
            get :index, :action => :list_content_view_definition_repositories,
              :on => :collection
            put :index, :action => :update_content_view_definition_repositories,
              :on => :collection
          end
        end
      end

      api_resources :content_view_definitions, :only => [:destroy, :content_views] do
        get :content_views, :on => :member
        put :content_views, :on => :member, :action => :update_content_views
      end
      api_resources :content_views, :only => [:promote, :show] do
        member do
          post :promote
          post :refresh
        end
      end

      api_resources :changesets, :only => [:show, :update, :destroy] do
        post :promote, :on => :member, :action => :promote
        post :apply, :on => :member, :action => :apply
        get :dependencies, :on => :member, :action => :dependencies

        api_attachable_resources :products, :controller => :changesets_content
        api_attachable_resources :packages, :controller => :changesets_content, :constraints => { :id => /[0-9a-zA-Z\-_.]+/ }
        api_attachable_resources :errata, :controller => :changesets_content
        api_attachable_resources :repositories, :controller => :changesets_content, :resource_name => :repo
        api_attachable_resources :distributions, :controller => :changesets_content
        api_attachable_resources :templates, :controller => :changesets_content
        api_attachable_resources :content_views, :controller => :changesets_content
      end

      api_resources :ping, :only => [:index]

      api_resources :repositories, :only => [:show, :create, :update, :destroy], :constraints => { :id => /[0-9a-zA-Z\-_.]*/ } do
        api_resources :sync, :only => [:index, :create] do
          delete :index, :on => :collection, :action => :cancel
        end
        api_resources :packages do
          get :search, :on => :collection
        end
        api_resources :errata, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.:]+/ }
        api_resources :distributions, :only => [:index, :show], :constraints => { :id => /[0-9a-zA-Z\-\+%_.]+/ }
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

      api_resources :environments, :only => [:show, :update, :destroy] do
        match '/systems' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
        api_resources :systems, :only => [:create, :index] do
          get :report, :on => :collection
        end
        api_resources :products, :only => [:index] do
          get :repositories, :on => :member
        end
        api_resources :activation_keys, :only => [:index, :create]
        api_resources :templates, :only => [:index]

        member do
          get :releases
        end
      end

      api_resources :gpg_keys, :only => [:show, :update, :destroy] do
        get :content, :on => :member
      end

      api_resources :activation_keys do
        post :pools, :action => :add_pool, :on => :member
        delete "pools/:poolid", :action => :remove_pool, :on => :member
      end

      api_resources :errata, :only => [:index]

      api_resources :users do
        get :report, :on => :collection
        get :sync_ldap_roles, :on => :collection
        api_resources :roles, :controller => :users, :only =>[] do
         post   :index, :on => :collection, :action => :add_role
         delete :destroy, :on => :member, :action => :remove_role
         get    :index, :on => :collection, :action => :list_roles
        end
      end
      api_resources :roles do
        get :available_verbs, :on => :collection, :action => :available_verbs
        api_resources :permissions, :only => [:index, :show, :create, :destroy]
        api_resources :ldap_groups, :controller => :role_ldap_groups , :only => [:create, :destroy, :index]
      end

      api_resources :tasks, :only => [:show]

      api_resources :crls, :only => [:index]

      match "/status"  => "ping#status", :via => :get
      match "/version"  => "ping#version", :via => :get
      # some paths conflicts with rhsm
      scope 'katello' do

        # routes for non-ActiveRecord-based resources
        match '/products/:id/repositories' => 'products#repo_create', :via => :post, :constraints => { :id => /[0-9\.]*/ }

      end

      # subscription-manager support
      match '/consumers' => 'systems#activate', :via => :post, :constraints => RegisterWithActivationKeyContraint.new
      match '/hypervisors' => 'systems#hypervisors_update', :via => :post
      api_resources :consumers, :controller => 'systems'
      match '/owners/:organization_id/environments' => 'environments#rhsm_index', :via => :get
      match '/owners/:organization_id/pools' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_pools_path
      match '/owners/:organization_id/servicelevels' => 'candlepin_proxies#get', :via => :get, :as => :proxy_owner_servicelevels_path
      match '/environments/:environment_id/consumers' => 'systems#index', :via => :get
      match '/environments/:environment_id/consumers' => 'systems#create', :via => :post
      match '/consumers/:id' => 'systems#regenerate_identity_certificates', :via => :post
      match '/users/:username/owners' => 'users#list_owners', :via => :get
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
      match '/entitlements/:id' => 'candlepin_proxies#get', :via => :get, :as => :proxy_entitlements_path
      match '/subscriptions' => 'candlepin_proxies#post', :via => :post, :as => :proxy_subscriptions_post_path
      match '/consumers/:id/profile/' => 'systems#upload_package_profile', :via => :put
      match '/consumers/:id/packages/' => 'systems#upload_package_profile', :via => :put

        # foreman proxy --------------
      if Katello.config.use_foreman
        scope :module => 'foreman' do
          api_resources :architectures, :except => [:new, :edit]
          api_resources :compute_resources, :except => [:new, :edit]
          api_resources :subnets, :except => [:new, :edit]
          api_resources :smart_proxies, :except => [:new, :edit]
          api_resources :hardware_models, :except => [:new, :edit]
          constraints(:id => /[^\/]+/) do
            api_resources :domains, :except => [:new, :edit]
          end
          api_resources :config_templates, :except => [:new, :edit] do
            collection do
              get :revision
              get :build_pxe_default
            end
          end
        end
      end

      # development / debugging support
      if Rails.env == "development"
        get 'status/memory'
      end

      # api custom information
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#create', :via => :post, :as => :create_custom_info
      match '/custom_info/:informable_type/:informable_id' => 'custom_info#index', :via => :get, :as => :custom_info
      match '/custom_info/:informable_type/:informable_id/:keyname' => 'custom_info#show', :via => :get, :as => :show_custom_info
      match '/custom_info/:informable_type/:informable_id/:keyname' => 'custom_info#update', :via => :put, :as => :update_custom_info
      match '/custom_info/:informable_type/:informable_id/:keyname' => 'custom_info#destroy', :via => :delete, :as => :destroy_custom_info

      match '*a', :to => 'errors#render_404'

    end # module v2


    # new v2 routes that point to v2
    scope :module => :v2, :constraints => ApiVersionConstraint.new(:version => 2, :default => true) do

    end # module v1

  end # '/api' namespace

end
