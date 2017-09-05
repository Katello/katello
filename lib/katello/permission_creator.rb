module Katello
  class PermissionCreator
    def initialize(plugin)
      @plugin = plugin
    end

    def define
      activation_keys_permissions
      capsule_content_permissions
      content_view_permissions
      gpg_key_permissions
      host_collections_permissions
      lifecycle_environment_permissions
      product_permissions
      subscription_permissions
      sync_plan_permissions
      user_permissions
    end

    def activation_keys_permissions
      @plugin.permission :view_activation_keys,
                         {
                           'katello/activation_keys' => [:all, :index],
                           'katello/api/v2/activation_keys' => [:index, :show, :available_host_collections, :available_releases,
                                                                :product_content, :auto_complete_search]
                         },
                         :resource_type => 'Katello::ActivationKey'
      @plugin.permission :create_activation_keys,
                         {
                           'katello/api/v2/activation_keys' => [:create, :copy]
                         },
                         :resource_type => 'Katello::ActivationKey'
      @plugin.permission :edit_activation_keys,
                         {
                           'katello/api/v2/activation_keys' => [:update, :content_override,
                                                                :add_subscriptions, :remove_subscriptions,
                                                                :add_host_collections, :remove_host_collections]
                         },
                         :resource_type => 'Katello::ActivationKey'
      @plugin.permission :destroy_activation_keys,
                         {
                           'katello/api/v2/activation_keys' => [:destroy]
                         },
                         :resource_type => 'Katello::ActivationKey'
    end

    def capsule_content_permissions
      @plugin.permission :manage_capsule_content,
                         {
                           'katello/api/v2/capsule_content' => [:add_lifecycle_environment, :remove_lifecycle_environment,
                                                                :sync, :cancel_sync],
                           'katello/api/v2/capsules' => [:index, :show]
                         },
                         :resource_type => 'SmartProxy'

      @plugin.permission :view_capsule_content,
                         {
                           'katello/api/v2/capsule_content' => [:lifecycle_environments, :available_lifecycle_environments, :sync_status],
                           'smart_proxies' => [:pulp_storage, :pulp_status, :show_with_content]
                         },
                         :resource_type => "SmartProxy"
    end

    def content_view_permissions # rubocop:disable Metrics/MethodLength
      @plugin.permission :view_content_views,
                 {
                   'katello/api/v2/content_views' => [:index, :show, :available_puppet_modules, :auto_complete_search,
                                                      :available_puppet_module_names],
                   'katello/api/v2/content_view_filters' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_filter_rules' => [:index, :show],
                   'katello/api/v2/content_view_histories' => [:index, :auto_complete_search],
                   'katello/api/v2/content_view_puppet_modules' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_versions' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_components' => [:index, :show],
                   'katello/api/v2/package_groups' => [:index, :show],
                   'katello/api/v2/errata' => [:index, :show],
                   'katello/api/v2/puppet_modules' => [:index, :show],
                   'katello/content_views' => [:auto_complete, :auto_complete_search],
                   'katello/errata' => [:short_details, :auto_complete],
                   'katello/packages' => [:details, :auto_complete],
                   'katello/products' => [:auto_complete],
                   'katello/repositories' => [:auto_complete_library],
                   'katello/content_search' => [:index,
                                                :products,
                                                :repos,
                                                :packages,
                                                :errata,
                                                :puppet_modules,
                                                :packages_items,
                                                :errata_items,
                                                :puppet_modules_items,
                                                :view_packages,
                                                :view_puppet_modules,
                                                :repo_packages,
                                                :repo_errata,
                                                :repo_puppet_modules,
                                                :repo_compare_errata,
                                                :repo_compare_packages,
                                                :repo_compare_puppet_modules,
                                                :view_compare_errata,
                                                :view_compare_packages,
                                                :view_compare_puppet_modules,
                                                :views]
                 },
                 :resource_type => 'Katello::ContentView'
      @plugin.permission :create_content_views,
                         {
                           'katello/api/v2/content_views' => [:create, :copy]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :edit_content_views,
                         {
                           'katello/api/v2/content_views' => [:update],
                           'katello/api/v2/content_view_filters' => [:create, :update, :destroy],
                           'katello/api/v2/content_view_filter_rules' => [:create, :update, :destroy],
                           'katello/api/v2/content_view_puppet_modules' => [:create, :update, :destroy],
                           'katello/api/v2/content_view_components' => [:add_components, :remove_components, :update]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :destroy_content_views,
                         {
                           'katello/api/v2/content_views' => [:destroy, :remove],
                           'katello/api/v2/content_view_versions' => [:destroy]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :publish_content_views,
                         {
                           'katello/api/v2/content_views' => [:publish],
                           'katello/api/v2/content_view_versions' => [:incremental_update, :republish_repositories]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :promote_or_remove_content_views,
                         {
                           'katello/api/v2/content_view_versions' => [:promote],
                           'katello/api/v2/content_views' => [:remove_from_environment, :remove, :republish_repositories]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :export_content_views,
                         {
                           'katello/api/v2/content_view_versions' => [:export]
                         },
                         :resource_type => 'Katello::ContentView'
    end

    def gpg_key_permissions
      @plugin.permission :view_gpg_keys,
                         {
                           'katello/api/v2/gpg_keys' => [:index, :show, :auto_complete_search]
                         },
                         :resource_type => 'Katello::GpgKey'
      @plugin.permission :create_gpg_keys,
                         {
                           'katello/api/v2/gpg_keys' => [:create]
                         },
                         :resource_type => 'Katello::GpgKey'
      @plugin.permission :edit_gpg_keys,
                         {
                           'katello/api/v2/gpg_keys' => [:update, :content]
                         },
                         :resource_type => 'Katello::GpgKey'
      @plugin.permission :destroy_gpg_keys,
                         {
                           'katello/api/v2/gpg_keys' => [:destroy]
                         },
                         :resource_type => 'Katello::GpgKey'
    end

    def host_collections_permissions
      @plugin.permission :view_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:index, :show, :auto_complete_search]
                         },
                         :resource_type => 'Katello::HostCollection'
      @plugin.permission :create_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:create, :copy]
                         },
                         :resource_type => 'Katello::HostCollection'
      @plugin.permission :edit_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:update, :add_hosts, :remove_hosts]
                         },
                         :resource_type => 'Katello::HostCollection'
      @plugin.permission :destroy_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:destroy]
                         },
                         :resource_type => 'Katello::HostCollection'
    end

    def lifecycle_environment_permissions
      @plugin.permission :view_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:index, :show, :paths, :repositories, :auto_complete_search],
                           'katello/api/rhsm/candlepin_proxies' => [:rhsm_index]
                         },
                         :resource_type => 'Katello::KTEnvironment'
      @plugin.permission :create_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:create]
                         },
                         :resource_type => 'Katello::KTEnvironment'
      @plugin.permission :edit_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:update]
                         },
                         :resource_type => 'Katello::KTEnvironment'
      @plugin.permission :destroy_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:destroy]
                         },
                         :resource_type => 'Katello::KTEnvironment'

      @plugin.permission :promote_or_remove_content_views_to_environments,
                         {},
                         :resource_type => 'Katello::KTEnvironment'
    end

    def product_permissions # rubocop:disable Metrics/MethodLength
      @plugin.permission :view_products,
                         {
                           'katello/products' => [:auto_complete, :auto_complete_search],
                           'katello/api/v2/products' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/repositories' => [:index, :show, :repository_types, :auto_complete_search, :cancel],
                           'katello/api/v2/packages' => [:index, :show, :auto_complete_search, :auto_complete_name, :auto_complete_arch],
                           'katello/api/v2/package_groups' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/docker_manifests' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/docker_tags' => [:index, :show, :auto_complete_search, :auto_complete_name],
                           'katello/api/v2/file_units' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/ostree_branches' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/errata' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/puppet_modules' => [:index, :show, :auto_complete_search],
                           'katello/errata' => [:short_details, :auto_complete],
                           'katello/packages' => [:details, :auto_complete],
                           'katello/puppet_modules' => [:show],
                           'katello/files' => [:auto_complete],
                           'katello/repositories' => [:auto_complete_library, :repository_types],
                           'katello/content_search' => [:index,
                                                        :products,
                                                        :repos,
                                                        :packages,
                                                        :errata,
                                                        :puppet_modules,
                                                        :packages_items,
                                                        :errata_items,
                                                        :puppet_modules_items,
                                                        :repo_packages,
                                                        :repo_errata,
                                                        :repo_puppet_modules,
                                                        :repo_compare_errata,
                                                        :repo_compare_packages,
                                                        :repo_compare_puppet_modules]
                         },
                         :resource_type => 'Katello::Product'
      @plugin.permission :create_products,
                         {
                           'katello/api/v2/products' => [:create],
                           'katello/api/v2/repositories' => [:create],
                           'katello/api/v2/package_groups' => [:create]
                         },
                         :resource_type => 'Katello::Product'
      @plugin.permission :edit_products,
                         {
                           'katello/api/v2/products' => [:update],
                           'katello/api/v2/repositories' => [:update, :remove_content, :import_uploads, :upload_content, :republish],
                           'katello/api/v2/products_bulk_actions' => [:update_sync_plans],
                           'katello/api/v2/content_uploads' => [:create, :update, :destroy],
                           'katello/api/v2/organizations' => [:repo_discover, :cancel_repo_discover]
                         },
                         :resource_type => 'Katello::Product'
      @plugin.permission :destroy_products,
                         {
                           'katello/api/v2/products' => [:destroy],
                           'katello/api/v2/repositories' => [:destroy],
                           'katello/api/v2/products_bulk_actions' => [:destroy_products],
                           'katello/api/v2/repositories_bulk_actions' => [:destroy_repositories],
                           'katello/api/v2/package_groups' => [:destroy]
                         },
                         :resource_type => 'Katello::Product'
      @plugin.permission :sync_products,
                         {
                           'katello/api/v2/products' => [:sync],
                           'katello/api/v2/repositories' => [:sync],
                           'katello/api/v2/products_bulk_actions' => [:sync_products],
                           'katello/api/v2/repositories_bulk_actions' => [:sync_repositories],
                           'katello/api/v2/sync' => [:index],
                           'katello/api/v2/sync_plans' => [:sync],
                           'katello/sync_management' => [:index, :sync_status, :product_status, :sync, :destroy]
                         },
                         :resource_type => 'Katello::Product'
      @plugin.permission :export_products,
                         {
                           'katello/api/v2/repositories' => [:export]
                         },
                         :resource_type => 'Katello::Product'
    end

    def subscription_permissions
      @plugin.permission :view_subscriptions,
                         {
                           'katello/api/v2/subscriptions' => [:index, :show, :available, :manifest_history, :auto_complete_search],
                           'katello/api/v2/repository_sets' => [:index, :show, :available_repositories]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :attach_subscriptions,
                         {
                           'katello/api/v2/subscriptions' => [:create]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :unattach_subscriptions,
                         {
                           'katello/api/v2/subscriptions' => [:destroy]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :import_manifest,
                         {
                           'katello/products' => [:available_repositories, :toggle_repository],
                           'katello/providers' => [:redhat_provider, :redhat_provider_tab],
                           'katello/api/v2/subscriptions' => [:upload, :refresh_manifest],
                           'katello/api/v2/repository_sets' => [:enable, :disable]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :delete_manifest,
                         {
                           'katello/api/v2/subscriptions' => [:delete_manifest]
                         },
                         :resource_type => 'Katello::Subscription'
    end

    def sync_plan_permissions
      @plugin.permission :view_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:index, :show, :add_products, :remove_products, :available_products, :auto_complete_search],
                           'katello/api/v2/products' => [:index]
                         },
                         :resource_type => 'Katello::SyncPlan'
      @plugin.permission :create_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:create]
                         },
                         :resource_type => 'Katello::SyncPlan'
      @plugin.permission :edit_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:update]
                         },
                         :resource_type => 'Katello::SyncPlan'
      @plugin.permission :destroy_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:destroy]
                         },
                         :resource_type => 'Katello::SyncPlan'
    end

    def user_permissions
      @plugin.permission :my_organizations,
                         {
                           'katello/api/rhsm/candlepin_proxies' => [:list_owners]
                         },
                         :public => true
    end
  end
end
