require 'katello/permission_creator'
require 'katello/repository_types.rb'
require 'katello/host_status_manager.rb'
# rubocop:disable Metrics/BlockLength
Foreman::Plugin.register :katello do
  requires_foreman '>= 2.6'

  sub_menu :top_menu, :content_menu, :caption => N_('Content'),
           :icon => 'fa fa-book', :after => :monitor_menu do
    menu :top_menu,
         :red_hat_subscriptions,
         :caption => N_('Subscriptions'),
         :url => '/subscriptions',
         :url_hash => {:controller => 'katello/api/v2/subscriptions',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :redhat_provider,
         :caption => N_('Red Hat Repositories'),
         :url => '/redhat_repositories',
         :url_hash => {:controller => 'katello/api/v2/repository_sets',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :products,
         :caption => N_('Products'),
         :url => '/products',
         :url_hash => {:controller => 'katello/api/v2/products',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :content_credentials,
         :caption => N_('Content Credentials'),
         :url => '/content_credentials',
         :url_hash => {:controller => 'katello/api/v2/content_credentials',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :sync_plans,
         :caption => N_('Sync Plans'),
         :url => '/sync_plans',
         :url_hash => {:controller => 'katello/api/v2/sync_plans',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :sync_status,
         :caption => N_('Sync Status'),
         :url_hash => {:controller => 'katello/sync_management',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :caption => N_('Lifecycle'), :parent => :content_menu

    menu :top_menu,
         :environments,
         :caption => N_('Lifecycle Environments'),
         :url => '/lifecycle_environments',
         :url_hash => {:controller => 'katello/api/v2/environments',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :content_views,
         :caption => N_('Content Views'),
         :url => '/content_views',
         :url_hash => {:controller => 'katello/api/v2/content_views',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :activation_keys,
         :caption => N_('Activation Keys'),
         :url => '/activation_keys',
         :url_hash => {:controller => 'katello/api/v2/activation_keys',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :caption => N_('Content Types'), :parent => :content_menu

    menu :top_menu,
         :debs,
         :caption => N_('Deb Packages'),
         :url => '/debs',
         :url_hash => {:controller => 'katello/api/v2/debs',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::DEB_TYPE) }

    menu :top_menu,
         :docker_tags,
         :caption => N_('Container Image Tags'),
         :url => '/docker_tags',
         :url_hash => {:controller => 'katello/api/v2/docker_tags',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::DOCKER_TYPE) }

    menu :top_menu,
         :files,
         :caption => N_('Files'),
         :url => '/files',
         :url_hash => {:controller => 'katello/api/v2/file_units',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::FILE_TYPE) }

    menu :top_menu,
         :packages,
         :caption => N_('Packages'),
         :url => '/packages',
         :url_hash => {:controller => 'katello/api/v2/packages',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::YUM_TYPE) }

    menu :top_menu,
         :errata,
         :caption => N_('Errata'),
         :url => '/errata',
         :url_hash => {:controller => 'katello/api/v2/errata',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::YUM_TYPE) }

    menu :top_menu,
         :module_streams,
         :caption => N_('Module Streams'),
         :url => '/module_streams',
         :url_hash => {:controller => 'katello/api/v2/module_streams',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::YUM_TYPE) }

    menu :top_menu,
         :ansible_collections,
         :caption => N_('Ansible Collections'),
         :url => '/ansible_collections',
         :url_hash => {:controller => 'katello/api/v2/ansible_collections',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { ::Katello::RepositoryTypeManager.enabled?(::Katello::Repository::ANSIBLE_COLLECTION_TYPE) }

    menu :top_menu,
         :other_content_types,
         :caption => N_('Other Content Types'),
         :url => '/content',
         :url_hash => {:controller => '/',
                       :action => ''},
         :engine => Katello::Engine,
         :turbolinks => false,
         :if => lambda { true }
  end

  menu :top_menu,
       :content_hosts,
       :caption => N_('Content Hosts'),
       :url => '/content_hosts',
       :url_hash => {:controller => 'api/v2/hosts',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :newhost,
       :turbolinks => false

  menu :top_menu,
       :host_collections,
       :caption => N_('Host Collections'),
       :url => '/host_collections',
       :url_hash => {:controller => 'katello/api/v2/host_collections',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :content_hosts,
       :turbolinks => false

  extend_template_helpers Katello::KatelloUrlsHelper
  extend_template_helpers Katello::Concerns::BaseTemplateScopeExtensions

  register_global_js_file 'global'

  search_path_override("Katello") do |resource|
    "/#{Katello::Util::Model.model_to_controller_path(resource)}/auto_complete_search"
  end
  apipie_documented_controllers ["#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"]
  apipie_ignored_controllers %w(::Api::V2::OrganizationsController)
  ApipieDSL.configuration.dsl_classes_matchers.concat [
    "#{Katello::Engine.root}/app/models/katello/**/*.rb",
    "#{Katello::Engine.root}/app/lib/actions/**/*.rb"
  ]

  parameter_filter ::Host::Managed, :host_collection_ids => [],
    :content_facet_attributes => [:content_view_id, :lifecycle_environment_id, :content_source_id,
                                  :host, :kickstart_repository_id],
    :subscription_facet_attributes => [:release_version, :autoheal, :purpose_usage, :purpose_role, :service_level, :host,
                                       {:installed_products => [:product_id, :product_name, :arch, :version]}, :facts, :hypervisor_guest_uuids => [], :purpose_addon_ids => []]
  parameter_filter ::Hostgroup, :content_view_id, :lifecycle_environment_id, :content_source_id,
    :kickstart_repository_id
  parameter_filter Organization, :label, :service_level
  parameter_filter SmartProxy, :download_policy, :lifecycle_environment_ids => []

  logger :glue, :enabled => true
  logger :pulp_rest, :enabled => true
  logger :cp_rest, :enabled => true
  logger :cp_proxy, :enabled => true
  logger :action, :enabled => true
  logger :manifest_import_logger, :enabled => true
  logger :registry_proxy, :enabled => true
  logger :katello_events, :enabled => true
  logger :candlepin_events, :enabled => true
  logger :agent, :enabled => true

  widget 'errata_widget', :name => 'Latest Errata', :sizey => 1, :sizex => 6
  widget 'content_views_widget', :name => 'Content Views', :sizey => 1, :sizex => 6
  widget 'sync_widget', :name => 'Sync Overview', :sizey => 1, :sizex => 6
  widget 'subscription_widget', :name => 'Host Subscription Status', :sizey => 1, :sizex => 6
  widget 'subscription_status_widget', :name => 'Subscription Status', :sizey => 1, :sizex => 6
  widget 'host_collection_widget', :name => 'Host Collections', :sizey => 1, :sizex => 6

  extend_page("smart_proxies/show") do |context|
    context.add_pagelet :main_tabs,
      :name => _("Content"),
      :partial => "foreman/smart_proxies/content_tab",
      :onlyif => proc { |proxy| proxy.pulp_mirror? }
    context.add_pagelet :details_content,
      :name => _("Content Sync"),
      :partial => "foreman/smart_proxies/content_sync",
      :onlyif => proc { |proxy| proxy.pulp_mirror? }
    context.add_pagelet :details_content,
      :name => _("Reclaim Space"),
      :partial => "foreman/smart_proxies/reclaim_space",
      :onlyif => proc { |proxy| proxy.pulp_primary? }
  end

  ::Katello::HostStatusManager::STATUSES.each do |status_class|
    register_custom_status(status_class)
  end

  register_ping_extension { Katello::Ping.ping }
  register_status_extension { Katello::Ping.status }

  extend_rabl_template 'api/v2/smart_proxies/main', 'katello/api/v2/smart_proxies/pulp_info'
  extend_rabl_template 'api/v2/hosts/show', 'katello/api/v2/hosts/host_collections'

  # Katello variables for Host Registration
  extend_allowed_registration_vars :activation_keys
  extend_allowed_registration_vars :lifecycle_environment_id
  extend_allowed_registration_vars :force
  extend_allowed_registration_vars :ignore_subman_errors

  extend_page "smart_proxies/show" do |cx|
    cx.add_pagelet :details_content,
                   :name => _('Storage'),
                   :partial => 'smart_proxies/show/storage',
                   :onlyif => proc { |proxy| proxy.has_feature?(SmartProxy::PULP_FEATURE) || proxy.has_feature?(SmartProxy::PULP_NODE_FEATURE) || proxy.has_feature?(SmartProxy::PULP3_FEATURE) }
  end

  register_facet Katello::Host::ContentFacet, :content_facet do
    configure_host do
      api_view :list => 'katello/api/v2/content_facet/base_with_root', :single => 'katello/api/v2/content_facet/show'
      api_docs :content_facet_attributes, ::Katello::Api::V2::HostContentsController
      template_compatibility_properties :content_source_id, :content_source
      extend_model ::Katello::Concerns::ContentFacetHostExtensions
    end

    configure_hostgroup(::Katello::Hostgroup::ContentFacet) do
      set_dependent_action :destroy
    end
  end

  register_facet Katello::Host::SubscriptionFacet, :subscription_facet do
    api_view :list => 'katello/api/v2/subscription_facet/base_with_root', :single => 'katello/api/v2/subscription_facet/show'
    api_docs :subscription_facet_attributes, ::Katello::Api::V2::HostSubscriptionsController
    extend_model ::Katello::Concerns::SubscriptionFacetHostExtensions
  end

  describe_host do
    overview_buttons_provider :content_host_overview_button
  end

  if Katello.with_remote_execution?
    RemoteExecutionFeature.register(:katello_package_install, N_("Katello: Install Package"), :description => N_("Install package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_package_update, N_("Katello: Update Package"), :description => N_("Update package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_package_remove, N_("Katello: Remove Package"), :description => N_("Remove package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_group_install, N_("Katello: Install Package Group"), :description => N_("Install package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_group_update, N_("Katello: Update Package Group"), :description => N_("Update package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_group_remove, N_("Katello: Remove Package Group"), :description => N_("Remove package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_errata_install, N_("Katello: Install Errata"), :description => N_("Install errata via Katello interface"), :provided_inputs => ['errata'])
    RemoteExecutionFeature.register(:katello_service_restart, N_("Katello: Service Restart"), :description => N_("Restart Services via Katello interface"), :provided_inputs => ['helpers'])
    RemoteExecutionFeature.register(:katello_host_tracer_resolve, N_("Katello: Resolve Traces"), :description => N_("Resolve traces via Katello interface"), :provided_inputs => ['ids'])
    RemoteExecutionFeature.register(:katello_module_stream_action, N_("Katello: Module Stream Actions"),
                                    :description => N_("Perform a module stream action via Katello interface"),
                                    :provided_inputs => ['action', 'module_spec', 'options'])
    allowed_template_helpers :errata

    RemoteExecutionProvider.singleton_class.prepend(Katello::Concerns::RemoteExecutionProviderExtensions)
  end

  tests_to_skip("AccessPermissionsTest" => [
                  'foreman_tasks/api/tasks/callback should have a permission that grants access',
                  'bastion/bastion/index should have a permission that grants access',
                  'bastion/bastion/index_ie should have a permission that grants access'
                ])

  add_controller_action_scope('HostsController', :index) do |base_scope|
    base_scope
      .preload(:content_view, :lifecycle_environment, :subscription_facet)
      .preload(content_facet: [:bound_repositories, :content_view, :lifecycle_environment])
  end

  add_controller_action_scope('Api::V2::HostsController', :index) do |base_scope|
    base_scope
      .preload(:content_view, :lifecycle_environment, :subscription_facet)
      .preload(content_facet: [:bound_repositories, :content_view, :lifecycle_environment])
  end

  register_info_provider Katello::Host::InfoProvider

  medium_providers_registry.register(Katello::ManagedContentMediumProvider)

  Katello::PermissionCreator.new(self).define
  add_all_permissions_to_default_roles
  unless Rails.env.test?
    add_permissions_to_default_roles 'System admin' => [:create_lifecycle_environments, :create_content_views]
  end
  role 'Register hosts', [
    :view_hostgroups, :view_activation_keys, :view_hosts,
    :create_hosts, :edit_hosts, :destroy_hosts,
    :view_content_views, :view_content_credentials, :view_subscriptions,
    :attach_subscriptions, :view_host_collections,
    :view_organizations, :view_lifecycle_environments, :view_products,
    :view_locations, :view_domains, :view_architectures,
    :view_operatingsystems, :view_smart_proxies
  ]

  role 'Content Importer', [
    :import_content, :create_products, :create_content_views,
    :edit_products, :edit_content_views, :view_organizations
  ], 'Role granting permission to import content views in an organization'

  role 'Content Exporter', [
    :export_content, :view_products, :view_content_views, :view_organizations
  ], 'Role granting permission to export content views in an organization'

  def find_katello_assets(args = {})
    type = args.fetch(:type, nil)
    vendor = args.fetch(:vendor, false)

    if vendor
      asset_dir = "#{Katello::Engine.root}/vendor/assets/#{type}/"
    else
      asset_dir = "#{Katello::Engine.root}/app/assets/#{type}/"
    end

    asset_paths = Dir[File.join(asset_dir, '**', '*')].reject { |file| File.directory?(file) }
    asset_paths.each { |file| file.slice!(asset_dir) }

    asset_paths
  end

  javascripts = find_katello_assets(:type => 'javascripts')
  images = find_katello_assets(:type => 'images')
  vendor_images = find_katello_assets(:type => 'images', :vendor => true)

  bastion_locale_files = Dir.glob("#{Katello::Engine.root}/engines/bastion/vendor/assets/javascripts/#{Bastion.localization_path("*")}")
  bastion_locale_files.map do |file|
    file.gsub!("#{Katello::Engine.root}/engines/bastion/vendor/assets/javascripts/", "")
  end

  precompile = [
    'katello/katello.css',
    'katello/containers/container.css',
    'bastion/bastion.css',
    'bastion/bastion.js',
    'bastion_katello/bastion_katello.css',
    'bastion_katello/bastion_katello.js',
    'katello/sync_management',
    'katello/common'
  ]

  precompile.concat(javascripts)
  precompile.concat(images)
  precompile.concat(vendor_images)
  precompile.concat(bastion_locale_files)

  precompile_assets(precompile)

  extend_observable_events(::Dynflow::Action.descendants.select { |klass| klass <= ::Actions::ObservableAction }.map(&:namespaced_event_names))
end
