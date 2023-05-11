require 'katello/permission_creator'
require 'katello/repository_types'
require 'katello/host_status_manager'
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
         :alternate_content_sources,
         :url => '/alternate_content_sources',
         :url_hash => {:controller => 'katello/api/v2/alternate_content_sources',
                       :action => 'index'},
         :caption => N_('Alternate Content Sources'),
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
         :url => '/content/ansible_collections',
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

  register_graphql_query_field :host_collection, '::Types::HostCollection', :record_field
  register_graphql_query_field :host_collections, '::Types::HostCollection', :collection_field

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
                                       {:installed_products => [:product_id, :product_name, :arch, :version]}, :facts, {:hypervisor_guest_uuids => []}, {:purpose_addon_ids => []}]
  parameter_filter ::Hostgroup, :content_view_id, :lifecycle_environment_id, :content_source_id,
    :kickstart_repository_id
  parameter_filter Organization, :label, :service_level
  parameter_filter SmartProxy, :download_policy, :http_proxy_id, :lifecycle_environment_ids => []

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

  extend_page 'hosts/_list' do |context|
    context.with_profile :content, _('Content'), default: false do
      common_class = 'hidden-tablet hidden-xs ellipsis'
      use_pagelet :hosts_table_column_header, :name
      use_pagelet :hosts_table_column_content, :name
      add_pagelet :hosts_table_column_header, key: :subscription_status, label: _('Subscription status'), sortable: true, class: common_class, width: '10%', export_key: 'subscription_global_status'
      add_pagelet :hosts_table_column_content, key: :subscription_status, class: common_class, callback: ->(host) { host_status_icon(host.subscription_global_status) }
      add_pagelet :hosts_table_column_header, key: :installable_updates, label: _('Installable updates'), class: common_class, width: '15%',
                  export_data: [:security, :bugfix, :enhancement].map { |kind| CsvExporter::ExportDefinition.new("installable_updates.#{kind}", callback: ->(host) { (host.content_facet_attributes&.errata_counts || {})[kind] }) } +
                               [:rpm, :deb].map { |kind| CsvExporter::ExportDefinition.new("installable_packages.#{kind}", callback: ->(host) { host&.content_facet_attributes&.public_send("upgradable_#{kind}_count".to_sym) || 0 }) }
      add_pagelet :hosts_table_column_content, key: :installable_updates, class: common_class, callback: ->(host) { errata_counts(host) }
      use_pagelet :hosts_table_column_header, :os_title
      use_pagelet :hosts_table_column_content, :os_title
      add_pagelet :hosts_table_column_header, key: :lifecycle_environment, label: _('Lifecycle environment'), sortable: true, class: common_class, width: '10%',
                  export_data: CsvExporter::ExportDefinition.new('single_lifecycle_environment', label: 'Lifecycle Environment')
      add_pagelet :hosts_table_column_content, key: :lifecycle_environment, class: common_class, callback: ->(host) { host.content_facet&.single_lifecycle_environment&.name }
      add_pagelet :hosts_table_column_header, key: :content_view, label: _('Content view'), sortable: true, class: common_class, width: '10%', export_data: CsvExporter::ExportDefinition.new('single_content_view', label: 'Content View')
      add_pagelet :hosts_table_column_content, key: :content_view, class: common_class, callback: ->(host) { host.content_facet&.single_content_view&.name }
      add_pagelet :hosts_table_column_header, key: :registered_at, label: _('Registered'), sortable: true, class: common_class, width: '10%', export_data: CsvExporter::ExportDefinition.new('subscription_facet_attributes.registered_at', label: 'Registered')
      add_pagelet :hosts_table_column_content, key: :registered_at, class: common_class, callback: ->(host) { host_registered_time(host) }
      add_pagelet :hosts_table_column_header, key: :last_checkin, label: _('Last checkin'), sortable: true, class: common_class, width: '10%', export_data: CsvExporter::ExportDefinition.new('subscription_facet_attributes.last_checkin', label: 'Last Checkin')
      add_pagelet :hosts_table_column_content, key: :last_checkin, class: common_class, callback: ->(host) { host_checkin_time(host) }
    end
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
    multiple_actions_provider :hosts_change_content_source
  end

  settings do
    category :katello, N_('Content') do
      http_proxy_select = [{
        name: _("HTTP Proxies"),
        class: 'HttpProxy',
        scope: 'all',
        value_method: 'name',
        text_method: 'name_and_url'
      }]
      download_policies = proc { hashify_parameters(::Katello::RootRepository::DOWNLOAD_POLICIES) }
      proxy_download_policies = proc { hashify_parameters(::SmartProxy::DOWNLOAD_POLICIES) }
      export_formats = proc { hashify_parameters(::Katello::Pulp3::ContentViewVersion::Export::FORMATS) }

      def hashify_parameters(parameters)
        Hash[parameters.map { |p| [p, p] }]
      end

      def katello_template_setting_values(name)
        templates = ProvisioningTemplate.where(:template_kind => TemplateKind.where(:name => name))
        templates.each_with_object({}) { |tmpl, hash| hash[tmpl.name] = tmpl.name }
      end

      setting 'allow_multiple_content_views',
        type: :boolean,
        default: false,
        full_name: N_('Allow multiple content views'),
        description: N_("Allow a host to be registered to multiple content view environments with 'subscription-manager register --environments'.") # TODO: update this description when AKs support this setting as well

      setting 'content_default_http_proxy',
        type: :string,
        default: nil,
        full_name: N_('Default HTTP Proxy'),
        description: N_("Default HTTP proxy for syncing content"),
        collection: proc { http_proxy_select },
        include_blank: N_("no global default")

      setting 'cdn_ssl_version',
        type: :string,
        default: nil,
        full_name: N_('CDN SSL version'),
        description: N_("SSL version used to communicate with the CDN"),
        collection: proc { hashify_parameters(Katello::Resources::CDN::SUPPORTED_SSL_VERSIONS) }

      setting 'katello_default_provision',
        type: :string,
        default: 'Kickstart default',
        full_name: N_('Default synced OS provisioning template'),
        description: N_("Default provisioning template for Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("provision") }

      setting 'katello_default_finish',
        type: :string,
        default: 'Kickstart default finish',
        full_name: N_('Default synced OS finish template'),
        description: N_("Default finish template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("finish") }

      setting 'katello_default_user_data',
        type: :string,
        default: 'Kickstart default user data',
        full_name: N_('Default synced OS user-data'),
        description: N_("Default user data for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("user_data") }

      setting 'katello_default_PXELinux',
        type: :string,
        default: 'Kickstart default PXELinux',
        full_name: N_('Default synced OS PXELinux template'),
        description: N_("Default PXELinux template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("PXELinux") }

      setting 'katello_default_PXEGrub',
        type: :string,
        default: 'Kickstart default PXEGrub',
        full_name: N_('Default synced OS PXEGrub template'),
        description: N_("Default PXEGrub template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("PXEGrub") }

      setting 'katello_default_PXEGrub2',
        type: :string,
        default: 'Kickstart default PXEGrub2',
        full_name: N_('Default synced OS PXEGrub2 template'),
        description: N_("Default PXEGrub2 template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("PXEGrub2") }

      setting 'katello_default_iPXE',
        type: :string,
        default: 'Kickstart default iPXE',
        full_name: N_('Default synced OS iPXE template'),
        description: N_("Default iPXE template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("iPXE") }

      setting 'katello_default_ptable',
        type: :string,
        default: 'Kickstart default',
        full_name: N_('Default synced OS partition table'),
        description: N_("Default partitioning table for new Operating Systems created from synced content"),
        collection: proc { Hash[Template.all.where(:type => "Ptable").map { |tmp| [tmp[:name], tmp[:name]] }] }

      setting 'katello_default_kexec',
        type: :string,
        default: 'Discovery Red Hat kexec',
        full_name: N_('Default synced OS kexec template'),
        description: N_("Default kexec template for new Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("kexec") }

      setting 'katello_default_atomic_provision',
        type: :string,
        default: 'Atomic Kickstart default',
        full_name: N_('Default synced OS Atomic template'),
        description: N_("Default provisioning template for new Atomic Operating Systems created from synced content"),
        collection: proc { katello_template_setting_values("provision") }

      setting 'manifest_refresh_timeout',
        type: :integer,
        default: 60 * 20,
        full_name: N_('Timeout when refreshing a manifest (in seconds)'),
        description: N_("Manifest refresh timeout")

      setting 'content_action_accept_timeout',
        type: :integer,
        default: 20,
        full_name: N_('Accept action timeout'),
        description: N_("Time in seconds to wait for a host to pick up a katello-agent action")

      setting 'content_action_finish_timeout',
        type: :integer,
        default: 3600,
        full_name: N_('Finish action timeout'),
        description: N_("Time in seconds to wait for a host to finish a katello-agent action")

      setting 'subscription_connection_enabled',
        type: :boolean,
        default: true,
        full_name: N_('Subscription connection enabled'),
        description: N_("Can communicate with the Red Hat Portal for subscriptions.")

      setting 'errata_status_installable',
        type: :boolean,
        default: false,
        full_name: N_('Generate errata status from directly-installable content'),
        description: N_("If true, only errata that can be installed without an incremental update will affect the host's errata status.")

      setting 'restrict_composite_view',
        type: :boolean,
        default: false,
        full_name: N_('Restrict composite content view promotion'),
        description: N_("If this is enabled, a composite content view may not be published or promoted unless the component content view versions that it includes exist in the target environment.")

      setting 'check_services_before_actions',
        type: :boolean,
        default: true,
        full_name: N_('Check services before actions'),
        description: N_("Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions.")

      setting 'foreman_proxy_content_batch_size',
        type: :integer,
        default: 100,
        full_name: N_('Batch size to sync repositories in.'),
        description: N_("How many repositories should be synced concurrently on the capsule. A smaller number may lead to longer sync times. A larger number will increase dynflow load.")

      setting 'foreman_proxy_content_auto_sync',
        type: :boolean,
        default: true,
        full_name: N_('Sync Smart Proxies after content view promotion'),
        description: N_("Whether or not to auto sync the Smart Proxies after a content view promotion.")

      setting 'download_rate_limit',
        type: :integer,
        default: 0,
        full_name: N_('Download rate limit'),
        description: N_("Maximum download rate when syncing a repository (requests per second). Use 0 for no limit.")

      setting 'default_download_policy',
        type: :string,
        default: "immediate",
        full_name: N_('Default Custom Repository download policy'),
        description: N_("Default download policy for custom repositories (either 'immediate' or 'on_demand')"),
        collection: download_policies

      setting 'default_redhat_download_policy',
        type: :string,
        default: "on_demand",
        full_name: N_('Default Red Hat Repository download policy'),
        description: N_("Default download policy for enabled Red Hat repositories (either 'immediate' or 'on_demand')"),
        collection: download_policies

      setting 'default_proxy_download_policy',
        type: :string,
        default: "on_demand",
        full_name: N_('Default Smart Proxy download policy'),
        description: N_("Default download policy for Smart Proxy syncs (either 'inherit', immediate', or 'on_demand')"),
        collection: proxy_download_policies

      setting 'pulp_export_destination',
        type: :string,
        default: "/var/lib/pulp/katello-export",
        full_name: N_('Pulp export destination filepath'),
        description: N_("On-disk location for exported repositories")

      setting 'pulpcore_export_destination',
        type: :string,
        default: "/var/lib/pulp/exports",
        full_name: N_('Pulp 3 export destination filepath'),
        description: N_("On-disk location for pulp 3 exported repositories")

      setting 'default_export_format',
        type: :string,
        default: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE,
        full_name: N_('Default export format'),
        description: N_("Default export format for content-exports(either 'syncable' or 'importable')"),
        collection: export_formats

      setting 'sync_total_timeout',
        type: :integer,
        default: 3600,
        full_name: N_('Sync Total Timeout'),
        description: N_("The maximum number of second that Pulp can take to do a single sync operation, e.g., download a single metadata file.")

      setting 'sync_connect_timeout_v2',
        type: :integer,
        default: 60,
        full_name: N_('Sync Connect Timeout'),
        description: N_("The maximum number of seconds for Pulp to establish a new connection or for waiting for a free connection from a pool if pool connection limits are exceeded.")

      setting 'sync_sock_connect_timeout',
        type: :integer,
        default: 60,
        full_name: N_('Sync Sock Connect Timeout'),
        description: N_("The maximum number of seconds for Pulp to connect to a peer for a new connection not given from a pool.")

      setting 'sync_sock_read_timeout',
        type: :integer,
        default: 3600,
        full_name: N_('Sync Sock Read Timeout'),
        description: N_("The maximum number of seconds that Pulp can take to download a file, not counting connection time.")

      setting 'remote_execution_by_default',
        type: :boolean,
        default: false,
        full_name: N_('Use remote execution by default'),
        description: N_("If this is enabled, remote execution is used instead of katello-agent for remote actions")

      setting 'unregister_delete_host',
        type: :boolean,
        default: false,
        full_name: N_('Delete Host upon unregister'),
        description: N_("When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host such as virtual machines and DNS records may also be deleted.")

      setting 'register_hostname_fact',
        type: :string,
        default: '',
        full_name: N_('Subscription manager name registration fact'),
        description: N_("When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')")

      setting 'register_hostname_fact_strict_match',
        type: :boolean,
        default: false,
        full_name: N_('Subscription manager name registration fact strict matching'),
        description: N_('If this is enabled, and register_hostname_fact is set and provided, registration will look for a new host by name only using that fact, and will skip all hostname matching')

      setting 'default_location_subscribed_hosts',
        type: :string,
        default: nil,
        full_name: N_('Default location for subscribed hosts'),
        description: N_('Default Location where new subscribed hosts will put upon registration'),
        collection: proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] }

      setting 'expire_soon_days',
        type: :integer,
        default: 120,
        full_name: N_('Expire soon days'),
        description: N_('The number of days remaining in a subscription before you will be reminded about renewing it.')

      setting 'content_view_solve_dependencies',
        type: :boolean,
        default: false,
        full_name: N_('content view Dependency Solving Default'),
        description: N_('The default dependency solving value for new content views.')

      setting 'host_dmi_uuid_duplicates',
        type: :array,
        default: [],
        full_name: N_('Host Duplicate DMI UUIDs'),
        description: N_("If hosts fail to register because of duplicate DMI UUIDs, add their comma-separated values here. Subsequent registrations will generate a unique DMI UUID for the affected hosts.")

      setting 'host_profile_assume',
        type: :boolean,
        default: true,
        full_name: N_('Host Profile Assume'),
        description: N_("Allow new host registrations to assume registered profiles with matching hostname as long as the registering DMI UUID is not used by another host.")

      setting 'host_profile_assume_build_can_change',
        type: :boolean,
        default: false,
        full_name: N_('Host Profile Can Change In Build'),
        description: N_("Allow host registrations to bypass 'Host Profile Assume' as long as the host is in build mode.")

      setting 'host_re_register_build_only',
        type: :boolean,
        default: false,
        full_name: N_('Host Can Re-Register Only In Build'),
        description: N_("Allow hosts to re-register themselves only when they are in build mode")

      setting 'host_tasks_workers_pool_size',
        type: :integer,
        default: 5,
        full_name: N_('Host Tasks Workers Pool Size'),
        description: N_("Amount of workers in the pool to handle the execution of host-related tasks. When set to 0, the default queue will be used instead. Restart of the dynflowd/foreman-tasks service is required.")

      setting 'applicability_batch_size',
        type: :integer,
        default: 50,
        full_name: N_('Applicability Batch Size'),
        description: N_("Number of host applicability calculations to process per task.")

      setting 'bulk_load_size',
        type: :integer,
        default: 2000,
        full_name: N_('Pulp bulk load size'),
        description: N_('The number of items fetched from a single paged Pulp API call.')

      setting 'upload_profiles_without_dynflow',
        type: :boolean,
        default: true,
        full_name: N_('Upload profiles without Dynflow'),
        description: N_('Allow Katello to update host installed packages, enabled repos, and module inventory directly instead of wrapped in Dynflow tasks (try turning off if Puma processes are using too much memory)')

      setting 'orphan_protection_time',
        type: :integer,
        default: 1440,
        full_name: N_('Orphaned Content Protection Time'),
        description: N_('Time in minutes before content that is not contained within a repository and has not been accessed is considered orphaned.')

      setting 'remote_execution_prefer_registered_through_proxy',
        type: :boolean,
        default: false,
        full_name: N_('Prefer registered through proxy for remote execution'),
        description: N_('Prefer using a proxy to which a host is registered when using remote execution')

      setting 'delete_repo_across_cv',
        type: :boolean,
        default: true,
        full_name: N_('Allow deleting repositories in published content views'),
        description: N_("If this is enabled, repositories can be deleted even when they belong to published content views. The deleted repository will be removed from all content view versions.")

      setting 'distribute_archived_cvv',
        type: :boolean,
        default: true,
        full_name: N_('Distribute archived content view versions'),
        description: N_("If this is enabled, repositories of content view versions without environments (\"archived\") will be distributed at '/pulp/content/<organization>/content_views/<content view>/X.Y/...'.")
    end
  end

  if Katello.with_remote_execution?
    RemoteExecutionFeature.register(:katello_package_install, N_("Katello: Install Package"), :description => N_("Install package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_package_install_by_search, N_("Katello: Install packages by search query"), :description => N_("Install packages via Katello interface"), :provided_inputs => ['Package search query'])
    RemoteExecutionFeature.register(:katello_package_update, N_("Katello: Update Package"), :description => N_("Update package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_packages_update_by_search, N_("Katello: Update Packages by search query"), :description => N_("Update packages via Katello interface"), :provided_inputs => ['Package search query'])
    RemoteExecutionFeature.register(:katello_package_remove, N_("Katello: Remove Package"), :description => N_("Remove package via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_packages_remove_by_search, N_("Katello: Remove Packages by search query"), :description => N_("Remove packages via Katello interface"), :provided_inputs => ['Package search query'])
    RemoteExecutionFeature.register(:katello_group_install, N_("Katello: Install Package Group"), :description => N_("Install package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_group_update, N_("Katello: Update Package Group"), :description => N_("Update package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_group_remove, N_("Katello: Remove Package Group"), :description => N_("Remove package group via Katello interface"), :provided_inputs => ['package'])
    RemoteExecutionFeature.register(:katello_errata_install, N_("Katello: Install Errata"), :description => N_("Install errata via Katello interface"), :provided_inputs => ['errata'])
    RemoteExecutionFeature.register(:katello_errata_install_by_search, N_("Katello: Install errata by search query"), :description => N_("Install errata using scoped search query"), :provided_inputs => ['Errata search query'])
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
      .preload(:subscription_facet)
      .preload(content_facet: [:bound_repositories])
  end

  add_controller_action_scope('Api::V2::HostsController', :index) do |base_scope|
    base_scope
      .preload(:subscription_facet)
      .preload(content_facet: [:bound_repositories])
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
