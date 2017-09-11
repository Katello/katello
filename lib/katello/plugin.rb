require 'katello/permission_creator'

Foreman::Plugin.register :katello do
  requires_foreman '>= 1.16'

  sub_menu :top_menu, :content_menu, :caption => N_('Content'), :after => :monitor_menu do
    menu :top_menu,
         :environments,
         :caption => N_('Lifecycle Environments'),
         :url => '/lifecycle_environments',
         :url_hash => {:controller => 'katello/api/v2/environments',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false
    menu :top_menu,
         :red_hat_subscriptions,
         :caption => N_('Red Hat Subscriptions'),
         :url => '/subscriptions',
         :url_hash => {:controller => 'katello/api/v2/subscriptions',
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

    divider :top_menu, :parent => :content_menu

    if Setting[:katello_experimental_ui]
      menu :top_menu,
           :redhat_provider,
           :caption => N_('Red Hat Repositories'),
           :url => '/redhat_repositories',
           :engine => Katello::Engine,
           :turbolinks => false
    else
      menu :top_menu,
           :redhat_provider,
           :caption => N_('Red Hat Repositories'),
           :url_hash => {:controller => 'katello/providers', :action => 'redhat_provider'},
           :engine => Katello::Engine,
           :turbolinks => false
    end

    menu :top_menu,
         :products,
         :caption => N_('Products'),
         :url => '/products',
         :url_hash => {:controller => 'katello/api/v2/products',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :gpg_keys,
         :caption => N_('GPG Keys'),
         :url => '/gpg_keys',
         :url_hash => {:controller => 'katello/api/v2/gpg_keys',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :sync_status,
         :caption => N_('Sync Status'),
         :url_hash => {:controller => 'katello/sync_management',
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

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :content_views,
         :caption => N_('Content Views'),
         :url => '/content_views',
         :url_hash => {:controller => 'katello/api/v2/content_views',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    divider :top_menu, :parent => :content_menu
    menu :top_menu,
         :errata,
         :caption => N_('Errata'),
         :url => '/errata',
         :url_hash => {:controller => 'katello/api/v2/errata',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :packages,
         :caption => N_('Packages'),
         :url => '/packages',
         :url_hash => {:controller => 'katello/api/v2/packages',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :puppet_modules,
         :caption => N_('Puppet Modules'),
         :url => '/puppet_modules',
         :url_hash => {:controller => 'katello/api/v2/puppet_modules',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :docker_tags,
         :caption => N_('Docker Tags'),
         :url => '/docker_tags',
         :url_hash => {:controller => 'katello/api/v2/docker_tags',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :files,
         :caption => N_('Files'),
         :url => '/files',
         :url_hash => {:controller => 'katello/api/v2/file_units',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false

    menu :top_menu,
         :ostree_branches,
         :caption => N_('OSTree Branches'),
         :url => '/ostree_branches',
         :url_hash => {:controller => 'katello/api/v2/ostree_branches',
                       :action => 'index'},
         :engine => Katello::Engine,
         :turbolinks => false
  end

  menu :top_menu,
       :content_hosts,
       :caption => N_('Content Hosts'),
       :url => '/content_hosts',
       :url_hash => {:controller => 'api/v2/hosts',
                     :action => 'index'},
       :engine => Katello::Engine,
       :parent => :hosts_menu,
       :after => :hosts,
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

  allowed_template_helpers :subscription_manager_configuration_url
  search_path_override("Katello") do |resource|
    "/#{Katello::Util::Model.model_to_controller_path(resource)}/auto_complete_search"
  end
  apipie_documented_controllers ["#{Katello::Engine.root}/app/controllers/katello/api/v2/*.rb"]
  apipie_ignored_controllers %w(::Api::V2::OrganizationsController)

  parameter_filter ::Host::Managed, :host_collection_ids => [],
    :content_facet_attributes => [:content_view_id, :lifecycle_environment_id, :content_source_id,
                                  :host, :kickstart_repository_id],
    :subscription_facet_attributes => [:release_version, :autoheal, :service_level, :host,
                                       {:installed_products => [:product_id, :product_name, :arch, :version]}, :facts, :hypervisor_guest_uuids => []]
  parameter_filter Hostgroup, :content_view_id, :lifecycle_environment_id, :content_source_id,
    :kickstart_repository_id
  parameter_filter Organization, :label, :service_level
  parameter_filter SmartProxy, :download_policy, :lifecycle_environment_ids => []

  logger :glue, :enabled => true
  logger :pulp_rest, :enabled => true
  logger :cp_rest, :enabled => true
  logger :cp_proxy, :enabled => true
  logger :action, :enabled => true
  logger :manifest_import_logger, :enabled => true

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
      :onlyif => proc { |proxy| proxy.has_feature?(SmartProxy::PULP_NODE_FEATURE) }
    context.add_pagelet :details_content,
      :name => _("Content Sync"),
      :partial => "foreman/smart_proxies/content_sync",
      :onlyif => proc { |proxy| proxy.has_feature?(SmartProxy::PULP_NODE_FEATURE) }
  end

  register_custom_status(Katello::ErrataStatus)
  register_custom_status(Katello::SubscriptionStatus)
  register_custom_status(Katello::TraceStatus)

  extend_page "smart_proxies/show" do |cx|
    cx.add_pagelet :details_content,
                   :name => _('Storage'),
                   :partial => 'smart_proxies/show/storage',
                   :onlyif => proc { |proxy| proxy.has_feature?(SmartProxy::PULP_FEATURE) || proxy.has_feature?(SmartProxy::PULP_NODE_FEATURE) }
  end

  register_facet Katello::Host::ContentFacet, :content_facet do
    api_view :list => 'katello/api/v2/content_facet/base_with_root', :single => 'katello/api/v2/content_facet/show'
    api_docs :content_facet_attributes, ::Katello::Api::V2::HostContentsController
    template_compatibility_properties :content_source_id, :content_source
  end

  register_facet Katello::Host::SubscriptionFacet, :subscription_facet do
    api_view :list => 'katello/api/v2/subscription_facet/base_with_root', :single => 'katello/api/v2/subscription_facet/show'
    api_docs :subscription_facet_attributes, ::Katello::Api::V2::HostSubscriptionsController
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
    allowed_template_helpers :errata
  end

  tests_to_skip("AccessPermissionsTest" => [
                  'foreman_tasks/api/tasks/callback should have a permission that grants access',
                  'bastion/bastion/index should have a permission that grants access',
                  'bastion/bastion/index_ie should have a permission that grants access'
                ])

  add_controller_action_scope(HostsController, :index) do |base_scope|
    base_scope
      .preload(:content_view, :lifecycle_environment, :subscription_facet)
      .preload(content_facet: [:bound_repositories, :content_view, :lifecycle_environment])
  end

  add_controller_action_scope(Api::V2::HostsController, :index) do |base_scope|
    base_scope
      .preload(:content_view, :lifecycle_environment, :subscription_facet)
      .preload(content_facet: [:bound_repositories, :content_view, :lifecycle_environment])
  end

  register_info_provider Katello::Host::InfoProvider

  Katello::PermissionCreator.new(self).define
  add_all_permissions_to_default_roles
end
