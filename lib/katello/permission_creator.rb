module Katello
  class PermissionCreator # rubocop:disable Metrics/ClassLength
    def initialize(plugin)
      @plugin = plugin
    end

    def define
      activation_keys_permissions
      capsule_content_permissions
      content_view_permissions
      content_credential_permissions
      host_collections_permissions
      lifecycle_environment_permissions
      organization_permissions
      product_permissions
      subscription_permissions
      sync_plan_permissions
      alternate_content_source_permissions
      user_permissions
    end

    def activation_keys_permissions
      @plugin.permission :view_activation_keys,
                         {
                           'katello/activation_keys' => [:all, :index],
                           'katello/api/v2/activation_keys' => [:index, :show, :available_host_collections, :available_releases,
                                                                :product_content, :auto_complete_search],
                           'katello/api/v2/repository_sets' => [:index, :auto_complete_search]
                         },
                         :resource_type => 'Katello::ActivationKey',
                         :finder_scope => :readable
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
                         :resource_type => 'Katello::ActivationKey',
                         :finder_scope => :editable
      @plugin.permission :destroy_activation_keys,
                         {
                           'katello/api/v2/activation_keys' => [:destroy]
                         },
                         :resource_type => 'Katello::ActivationKey',
                         :finder_scope => :deletable
    end

    def capsule_content_permissions
      @plugin.permission :manage_capsule_content,
                         {
                           'katello/api/v2/capsule_content' => [:add_lifecycle_environment, :remove_lifecycle_environment,
                                                                :sync, :reclaim_space, :cancel_sync],
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

    def content_view_permissions
      @plugin.permission :view_content_views,
                 {
                   'katello/api/v2/content_views' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_filters' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_filter_rules' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_histories' => [:index, :auto_complete_search],
                   'katello/api/v2/content_view_repositories' => [:show_all],
                   'katello/api/v2/content_view_versions' => [:index, :show, :auto_complete_search],
                   'katello/api/v2/content_view_components' => [:index, :show, :show_all],
                   'katello/api/v2/debs' => [:index],
                   'katello/api/v2/packages' => [:index],
                   'katello/api/v2/package_groups' => [:index, :show, :auto_complete_search, :compare],
                   'katello/api/v2/errata' => [:index, :show, :auto_complete_search, :compare],
                   'katello/api/v2/module_streams' => [:index, :show, :auto_complete_search, :compare],
                   'katello/api/v2/ansible_collections' => [:index, :show, :auto_complete_search, :compare],
                   'katello/api/v2/repositories' => [:index, :show, :auto_complete_search, :compare],
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
                                                :packages_items,
                                                :errata_items,
                                                :module_streams,
                                                :ansible_collections,
                                                :view_packages,
                                                :repo_packages,
                                                :repo_errata,
                                                :repo_compare_errata,
                                                :repo_compare_packages,
                                                :view_compare_errata,
                                                :view_compare_packages,
                                                :views]
                 },
                 :resource_type => 'Katello::ContentView',
                 :finder_scope => :readable
      @plugin.permission :create_content_views,
                         {
                           'katello/api/v2/content_views' => [:create, :copy]
                         },
                         :resource_type => 'Katello::ContentView'
      @plugin.permission :edit_content_views,
                         {
                           'katello/api/v2/content_views' => [:update, :remove_filters],
                           'katello/api/v2/content_view_versions' => [:update],
                           'katello/api/v2/content_view_filters' => [:create, :update, :destroy, :remove_filter_rules, :add_filter_rules],
                           'katello/api/v2/content_view_filter_rules' => [:create, :update, :destroy],
                           'katello/api/v2/content_view_components' => [:add_components, :remove_components, :update]
                         },
                         :resource_type => 'Katello::ContentView',
                         :finder_scope => :editable
      @plugin.permission :destroy_content_views,
                         {
                           'katello/api/v2/content_views' => [:destroy, :remove, :bulk_delete_versions],
                           'katello/api/v2/content_view_versions' => [:destroy]
                         },
                         :resource_type => 'Katello::ContentView',
                         :finder_scope => :deletable
      @plugin.permission :publish_content_views,
                         {
                           'katello/api/v2/content_views' => [:publish],
                           'katello/api/v2/content_view_versions' => [:incremental_update, :republish_repositories],
                           'katello/api/v2/content_imports' => [:version, :index]
                         },
                         :resource_type => 'Katello::ContentView',
                         :finder_scope => :publishable
      @plugin.permission :promote_or_remove_content_views,
                         {
                           'katello/api/v2/content_view_versions' => [:promote],
                           'katello/api/v2/content_views' => [:remove_from_environment, :remove, :republish_repositories]
                         },
                         :resource_type => 'Katello::ContentView',
                         :finder_scope => :promotable_or_removable
    end

    def content_credential_permissions
      @plugin.permission :view_content_credentials,
                         {
                           'katello/api/v2/content_credentials' => [:index, :show, :content, :auto_complete_search],
                           'katello/api/v2/gpg_keys' => [:index, :show, :content, :auto_complete_search]
                         },
                         :resource_type => 'Katello::ContentCredential',
                         :finder_scope => :readable
      @plugin.permission :create_content_credentials,
                         {
                           'katello/api/v2/content_credentials' => [:create],
                           'katello/api/v2/gpg_keys' => [:create]
                         },
                         :resource_type => 'Katello::ContentCredential'
      @plugin.permission :edit_content_credentials,
                         {
                           'katello/api/v2/content_credentials' => [:update, :set_content],
                           'katello/api/v2/gpg_keys' => [:update, :set_content]
                         },
                         :resource_type => 'Katello::ContentCredential',
                         :finder_scope => :editable
      @plugin.permission :destroy_content_credentials,
                         {
                           'katello/api/v2/content_credentials' => [:destroy],
                           'katello/api/v2/gpg_keys' => [:destroy]
                         },
                         :resource_type => 'Katello::ContentCredential',
                         :finder_scope => :deletable
    end

    def host_collections_permissions
      @plugin.permission :view_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:index, :show, :auto_complete_search]
                         },
                         :resource_type => 'Katello::HostCollection',
                         :finder_scope => :readable
      @plugin.permission :create_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:create, :copy]
                         },
                         :resource_type => 'Katello::HostCollection',
                         :finder_scope => :creatable
      @plugin.permission :edit_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:update, :add_hosts, :remove_hosts]
                         },
                         :resource_type => 'Katello::HostCollection',
                         :finder_scope => :editable
      @plugin.permission :destroy_host_collections,
                         {
                           'katello/api/v2/host_collections' => [:destroy]
                         },
                         :resource_type => 'Katello::HostCollection',
                         :finder_scope => :deletable
    end

    def lifecycle_environment_permissions
      @plugin.permission :view_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:index, :show, :paths, :repositories, :auto_complete_search],
                           'katello/api/rhsm/candlepin_proxies' => [:rhsm_index]
                         },
                         :resource_type => 'Katello::KTEnvironment',
                         :finder_scope => :readable
      @plugin.permission :create_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:create]
                         },
                         :resource_type => 'Katello::KTEnvironment',
                         :finder_scope => :creatable
      @plugin.permission :edit_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:update]
                         },
                         :resource_type => 'Katello::KTEnvironment',
                         :finder_scope => :editable
      @plugin.permission :destroy_lifecycle_environments,
                         {
                           'katello/api/v2/environments' => [:destroy]
                         },
                         :resource_type => 'Katello::KTEnvironment',
                         :finder_scope => :deletable
      @plugin.permission :promote_or_remove_content_views_to_environments,
                         {},
                         :resource_type => 'Katello::KTEnvironment',
                         :finder_scope => :promotable
    end

    def product_permissions
      @plugin.permission :view_products,
                         {
                           'katello/products' => [:auto_complete, :auto_complete_search],
                           'katello/api/v2/products' => [:index, :show, :auto_complete_search],
                           'katello/api/v2/repositories' => [:index, :show, :repository_types, :content_types, :auto_complete_search, :cancel],
                           'katello/api/v2/packages' => [:index, :show, :auto_complete_search, :auto_complete_name, :auto_complete_arch, :compare],
                           'katello/api/v2/srpms' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/debs' => [:index, :show, :auto_complete_search, :auto_complete_name, :auto_complete_arch, :compare],
                           'katello/api/v2/package_groups' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/docker_manifests' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/docker_manifest_lists' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/docker_tags' => [:index,
                                                            :show,
                                                            :auto_complete_search,
                                                            :auto_complete_name,
                                                            :compare,
                                                            :repositories],
                           'katello/api/v2/file_units' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/errata' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/module_streams' => [:index, :show, :auto_complete_search, :compare, :auto_complete_name],
                           'katello/api/v2/ansible_collections' => [:index, :show, :auto_complete_search, :compare],
                           'katello/api/v2/generic_content_units' => [:index, :show, :auto_complete_search, :compare],
                           'katello/errata' => [:short_details, :auto_complete],
                           'katello/packages' => [:details, :auto_complete],
                           'katello/files' => [:auto_complete],
                           'katello/generic' => [:auto_complete],
                           'katello/repositories' => [:auto_complete_library, :repository_types],
                           'katello/content_search' => [:index,
                                                        :products,
                                                        :repos,
                                                        :packages,
                                                        :errata,
                                                        :packages_items,
                                                        :errata_items,
                                                        :module_streams,
                                                        :ansible_collections,
                                                        :repo_packages,
                                                        :repo_errata,
                                                        :repo_compare_errata,
                                                        :repo_compare_packages],
                           'katello/api/v2/repository_sets' => [:index, :show, :available_repositories, :auto_complete_search]
                         },
                         :resource_type => 'Katello::Product',
                         :finder_scope => :readable
      @plugin.permission :create_products,
                         {
                           'katello/api/v2/products' => [:create]
                         },
                         :resource_type => 'Katello::Product',
                         :finder_scope => :editable
      @plugin.permission :edit_products,
                         {
                           'katello/api/v2/products' => [:update],
                           'katello/api/v2/repositories' => [:create, :update, :remove_content, :import_uploads, :upload_content, :republish, :verify_checksum, :reclaim_space],
                           'katello/api/v2/products_bulk_actions' => [:update_sync_plans, :update_http_proxy, :verify_checksum_products],
                           'katello/api/v2/content_uploads' => [:create, :update, :destroy],
                           'katello/api/v2/organizations' => [:repo_discover, :cancel_repo_discover],
                           'katello/api/v2/repository_sets' => [:enable, :disable]
                         },
                         :resource_type => 'Katello::Product',
                         :finder_scope => :editable
      @plugin.permission :destroy_products,
                         {
                           'katello/api/v2/products' => [:destroy],
                           'katello/api/v2/repositories' => [:destroy],
                           'katello/api/v2/products_bulk_actions' => [:destroy_products],
                           'katello/api/v2/repositories_bulk_actions' => [:destroy_repositories]
                         },
                         :resource_type => 'Katello::Product',
                         :finder_scope => :deletable
      @plugin.permission :sync_products,
                         {
                           'katello/api/v2/products' => [:sync],
                           'katello/api/v2/repositories' => [:sync],
                           'katello/api/v2/products_bulk_actions' => [:sync_products],
                           'katello/api/v2/repositories_bulk_actions' => [:sync_repositories, :reclaim_space_from_repositories],
                           'katello/api/v2/sync' => [:index],
                           'katello/sync_management' => [:index, :sync_status, :product_status, :sync, :destroy]
                         },
                         :resource_type => 'Katello::Product',
                         :finder_scope => :syncable
    end

    def subscription_permissions
      @plugin.permission :view_subscriptions,
                         {
                           'katello/api/v2/subscriptions' => [:index, :show, :available, :manifest_history, :auto_complete_search]
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
                           'katello/api/v2/subscriptions' => [:upload, :refresh_manifest]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :delete_manifest,
                         {
                           'katello/api/v2/subscriptions' => [:delete_manifest]
                         },
                         :resource_type => 'Katello::Subscription'
      @plugin.permission :manage_subscription_allocations,
                         {
                           'katello/api/v2/upstream_subscriptions' => [:index, :create, :destroy, :update, :ping, :enable_simple_content_access, :disable_simple_content_access, :simple_content_access_eligible, :simple_content_access_status],
                           'katello/api/v2/simple_content_access' => [:enable, :disable, :eligible, :status]
                         },
                         :resource_type => 'Katello::Subscription'
    end

    def sync_plan_permissions
      @plugin.permission :view_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:index, :show, :add_products, :remove_products, :available_products, :auto_complete_search]
                         },
                         :resource_type => 'Katello::SyncPlan',
                         :finder_scope => :readable
      @plugin.permission :create_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:create]
                         },
                         :resource_type => 'Katello::SyncPlan',
                         :finder_scope => :editable
      @plugin.permission :edit_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:update]
                         },
                         :resource_type => 'Katello::SyncPlan',
                         :finder_scope => :editable
      @plugin.permission :destroy_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:destroy]
                         },
                         :resource_type => 'Katello::SyncPlan',
                         :finder_scope => :deletable
      @plugin.permission :sync_sync_plans,
                         {
                           'katello/api/v2/sync_plans' => [:sync]
                         },
                         :resource_type => 'Katello::SyncPlan',
                         :finder_scope => :syncable
    end

    def alternate_content_source_permissions
      @plugin.permission :view_alternate_content_sources,
                         {
                           'katello/api/v2/alternate_content_sources' => [:index, :show, :auto_complete_search]
                         },
                         :resource_type => 'Katello::AlternateContentSource',
                         :finder_scope => :readable
      @plugin.permission :create_alternate_content_sources,
                         {
                           'katello/api/v2/alternate_content_sources' => [:create]
                         },
                         :resource_type => 'Katello::AlternateContentSource',
                         :finder_scope => :editable
      @plugin.permission :edit_alternate_content_sources,
                         {
                           'katello/api/v2/alternate_content_sources' => [:update, :refresh],
                           'katello/api/v2/alternate_content_sources_bulk_actions' => [:refresh_alternate_content_sources, :refresh_all_alternate_content_sources]
                         },
                         :resource_type => 'Katello::AlternateContentSource',
                         :finder_scope => :editable
      @plugin.permission :destroy_alternate_content_sources,
                         {
                           'katello/api/v2/alternate_content_sources' => [:destroy],
                           'katello/api/v2/alternate_content_sources_bulk_actions' => [:destroy_alternate_content_sources]
                         },
                         :resource_type => 'Katello::AlternateContentSource',
                         :finder_scope => :deletable
    end

    def user_permissions
      @plugin.permission :my_organizations,
                         {
                           'katello/api/rhsm/candlepin_proxies' => [:list_owners]
                         },
                         :public => true
    end

    def organization_permissions
      @plugin.permission :import_content,
                         {
                           'katello/api/v2/content_imports' => [:library, :version, :index, :repository]
                         },
                         :resource_type => 'Organization'

      @plugin.permission :export_content,
                         {
                           'katello/api/v2/content_view_versions' => [:export, :repository],
                           'katello/api/v2/content_exports' => [:library, :version, :index, :repository],
                           'katello/api/v2/content_export_incrementals' => [:library, :version, :repository]
                         },
                         :resource_type => 'Organization'
    end
  end
end
