class Setting::Content < Setting
  #rubocop:disable Metrics/AbcSize

  validate :content_default_http_proxy, if: proc { |s| s.name == 'content_default_http_proxy' && HttpProxy.table_exists? }

  after_save :add_organizations_and_locations_if_global_http_proxy

  def self.hashify_parameters(parameters)
    Hash[parameters.map { |p| [p, p] }]
  end

  def self.default_settings
    download_policies = proc { hashify_parameters(::Katello::RootRepository::DOWNLOAD_POLICIES) }

    proxy_download_policies = proc { hashify_parameters(::SmartProxy::DOWNLOAD_POLICIES) }
    cdn_ssl_versions = proc { hashify_parameters(Katello::Resources::CDN::SUPPORTED_SSL_VERSIONS) }
    http_proxy_select = [{
      name: _("HTTP Proxies"),
      class: 'HttpProxy',
      scope: 'all',
      value_method: 'name',
      text_method: 'name_and_url'
    }]

    [
      self.set('content_default_http_proxy', N_("Default HTTP Proxy for syncing content"),
                      nil, N_('Default HTTP proxy'),
                      nil,
                      collection: proc { http_proxy_select }, include_blank: N_("no global default")
              ),
      self.set('cdn_ssl_version', N_("SSL version used to communicate with the CDN"),
               nil, N_('CDN SSL version'), nil,
               :collection => cdn_ssl_versions),
      self.set('katello_default_provision', N_("Default provisioning template for Operating Systems created from synced content"),
               'Kickstart default', N_('Default synced OS provisioning template'),
               nil, :collection => proc { katello_template_setting_values("provision") }
              ),
      self.set('katello_default_finish',
               N_("Default finish template for new Operating Systems created from synced content"),
               'Kickstart default finish', N_('Default synced OS finish template'),
               nil, :collection => proc { katello_template_setting_values("finish") }
              ),
      self.set('katello_default_user_data', N_("Default user data for new Operating Systems created from synced content"),
               'Kickstart default user data', N_('Default synced OS user-data'),
               nil, :collection => proc { katello_template_setting_values("user_data") }
              ),
      self.set('katello_default_PXELinux', N_("Default PXELinux template for new Operating Systems created from synced content"),
               'Kickstart default PXELinux', N_('Default synced OS PXELinux template'),
               nil, :collection => proc { katello_template_setting_values("PXELinux") }
              ),
      self.set('katello_default_PXEGrub', N_("Default PXEGrub template for new Operating Systems created from synced content"),
               'Kickstart default PXEGrub', N_('Default synced OS PXEGrub template'),
               nil, :collection => proc { katello_template_setting_values("PXEGrub") }
              ),
      self.set('katello_default_PXEGrub2', N_("Default PXEGrub2 template for new Operating Systems created from synced content"),
               'Kickstart default PXEGrub2', N_('Default synced OS PXEGrub2 template'),
               nil, :collection => proc { katello_template_setting_values("PXEGrub2") }
              ),
      self.set('katello_default_iPXE', N_("Default iPXE template for new Operating Systems created from synced content"),
               'Kickstart default iPXE', N_('Default synced OS iPXE template'),
               nil, :collection => proc { katello_template_setting_values("iPXE") }
              ),
      self.set('katello_default_ptable', N_("Default partitioning table for new Operating Systems created from synced content"),
               'Kickstart default', N_('Default synced OS partition table'),
               nil, :collection => proc { Hash[Template.all.where(:type => "Ptable").map { |tmp| [tmp[:name], tmp[:name]] }] }
              ), self.set('katello_default_kexec', N_("Default kexec template for new Operating Systems created from synced content"), 'Discovery Red Hat kexec', N_('Default synced OS kexec template'),
               nil, :collection => proc { katello_template_setting_values("kexec") }
              ),
      self.set('katello_default_atomic_provision', N_("Default provisioning template for new Atomic Operating Systems created from synced content"),
               'Atomic Kickstart default', N_('Default synced OS Atomic template'),
               nil, :collection => proc { katello_template_setting_values("provision") }
              ),
      self.set('manifest_refresh_timeout', N_('Timeout when refreshing a manifest (in seconds)'), 60 * 20, N_("Manifest refresh timeout")),
      self.set('content_action_accept_timeout', N_("Time in seconds to wait for a Host to pickup a remote action"),
               20, N_('Accept action timeout')),
      self.set('content_action_finish_timeout', N_("Time in seconds to wait for a Host to finish a remote action"),
               3600, N_('Finish action timeout')),
      self.set('subscription_connection_enabled', N_("Can communicate with the Red Hat Portal for subscriptions."),
               true, N_('Subscription connection enabled')),
      self.set('errata_status_installable', N_("Calculate errata host status based only on errata in a Host's Content View and Lifecycle Environment"),
               false, N_('Installable errata from Content View')),
      self.set('restrict_composite_view', N_("If this is enabled, a composite content view may not be published or "\
               "promoted, unless the component content view versions that it includes exist in the target environment."),
               false, N_('Restrict Composite Content View promotion')),
      self.set('check_services_before_actions', N_("Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions."),
               true, N_('Check services before actions')),
      self.set('foreman_proxy_content_batch_size', N_("How many repositories should be synced concurrently on the capsule.  A smaller number may lead to longer sync times.  A larger number will increase dynflow load."),
               100, N_('Batch size to sync repositories in.')),
      self.set('foreman_proxy_content_auto_sync', N_("Whether or not to auto sync the Smart Proxies after a Content View promotion."),
               true, N_('Sync Smart Proxies after Content View promotion')),
      self.set('download_rate_limit', N_("Maximum download rate when syncing a repository (requests per second). Use 0 for no limit."), 0, N_("Download rate limit")),
      self.set('default_download_policy', N_("Default download policy for custom repositories (either 'immediate' or 'on_demand')"), "immediate",
               N_('Default Custom Repository download policy'), nil, :collection => download_policies),
      self.set('default_redhat_download_policy', N_("Default download policy for enabled Red Hat repositories (either 'immediate' or 'on_demand')"), "on_demand",
                       N_('Default Red Hat Repository download policy'), nil, :collection => download_policies),
      self.set('default_proxy_download_policy', N_("Default download policy for Smart Proxy syncs (either 'inherit', immediate', or 'on_demand')"), "on_demand",
               N_('Default Smart Proxy download policy'), nil, :collection => proxy_download_policies),
      self.set('pulp_docker_registry_port', N_("The port used by Pulp Crane to provide Docker Registries"),
               5000, N_('Pulp Docker registry port')),
      self.set('pulp_export_destination', N_("On-disk location for exported repositories"),
               "/var/lib/pulp/katello-export", N_('Pulp export destination filepath')),
      self.set('pulpcore_export_destination', N_("On-disk location for pulp 3 exported repositories"),
               "/var/lib/pulp/exports", N_('Pulp 3 export destination filepath')),
      self.set('pulp_client_key', N_("Path for ssl key used for pulp server auth"),
               "/etc/pki/katello/private/pulp-client.key", N_('Pulp client key')),
      self.set('pulp_client_cert', N_("Path for ssl cert used for pulp server auth"),
               "/etc/pki/katello/certs/pulp-client.crt", N_('Pulp client cert')),
      self.set('sync_connect_timeout', N_("Total timeout in seconds for connections when syncing"),
               300, N_('Sync Connection Timeout')),
      self.set('remote_execution_by_default', N_("If this is enabled, remote execution is used instead of katello-agent for remote actions"),
               false, N_('Use remote execution by default')),
      self.set('unregister_delete_host', N_("When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host " \
                                            "such as virtual machines and DNS records may also be deleted."),
               false, N_('Delete Host upon unregister')),
      self.set('register_hostname_fact', N_("When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')"),
               '', N_('Subscription manager name registration fact'), nil),
      self.set('register_hostname_fact_strict_match', N_('If this is enabled, and register_hostname_fact is set and provided, registration will look for a new host by name only '\
                'using that fact, and will skip all hostname matching'), false, N_('Subscription manager name registration fact strict matching'), nil),
      self.set('default_location_subscribed_hosts',
               N_('Default Location where new subscribed hosts will put upon registration'),
               nil, N_('Default Location subscribed hosts'), nil,
               :collection => proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] }),
      self.set('expire_soon_days', N_('The number of days remaining in a subscription before you will be reminded about renewing it.'),
               120, N_('Expire soon days')),
      self.set('content_view_solve_dependencies',
               N_('The default dependency solving value for new Content Views.'),
               false, N_('Content View Dependency Solving Default')),
      self.set('host_dmi_uuid_duplicates',
               N_("If hosts fail to register because of duplicate DMI UUIDs " \
                  "add their comma-separated values here. Subsequent registrations will generate a unique DMI UUID for the affected hosts."),
               [], N_('Host Duplicate DMI UUIDs')),
      self.set('host_profile_assume', N_("Allow new Host registrations to assume registered profiles with matching hostname " \
                  "as long as the registering DMI UUID is not used by another host."),
               true, N_('Host Profile Assume')),
      self.set('host_profile_assume_build_can_change', N_("Allow Host registrations to bypass 'Host Profile Assume' " \
                  "as long as the host is in build mode."),
               false, N_('Host Profile Can Change In Build')),
      self.set('host_re_register_build_only', N_("Allow hosts to re-register themselves only when they are in build mode"),
               false, N_('Host Can Re-Register Only In Build')),
      self.set('host_tasks_workers_pool_size', N_("Amount of workers in the pool to handle the execution of host-related tasks. When set to 0, the default queue will be used instead. Restart of the dynflowd/foreman-tasks service is required."),
               5, N_('Host Tasks Workers Pool Size')),
      self.set('applicability_batch_size', N_("Number of host applicability calculations to process per task."),
               50, N_('Applicability Batch Size')),
      self.set('autosearch_while_typing', N_('For pages that support it, automatically perform search while typing in search input.'),
               true, N_('Autosearch')),
      self.set('autosearch_delay', N_('If Autosearch is enabled, delay in milliseconds before executing searches while typing.'),
               500, N_('Autosearch delay')),
      self.set('bulk_load_size', N_('The number of items fetched from a single paged Pulp API call.'), 2000,
               N_('Pulp bulk load size')),
      self.set('upload_profiles_without_dynflow', N_('Allow Katello to update host installed packages, enabled repos, and module inventory directly instead of wrapped in Dynflow tasks (try turning off if Puma processes are using too much memory)'), true,
               N_('Upload profiles without Dynflow')),
      self.set('orphan_protection_time', N_('Time in minutes to consider orphan content as orphaned.'), 1440, N_('Orphaned Content Protection Time')),
      self.set('remote_execution_prefer_registered_through_proxy', N_('Prefer using a proxy to which a host is registered when using remote execution'), false,
               N_('Prefer registered through proxy for remote execution'))
    ]
  end

  def self.load_defaults
    BLANK_ATTRS.concat %w(register_hostname_fact default_location_subscribed_hosts
                          content_default_http_proxy host_dmi_uuid_duplicates cdn_ssl_version)
    super
  end

  def self.katello_template_setting_values(name)
    templates = ProvisioningTemplate.where(:template_kind => TemplateKind.where(:name => name))
    templates.each_with_object({}) { |tmpl, hash| hash[tmpl.name] = tmpl.name }
  end

  def add_organizations_and_locations_if_global_http_proxy
    if name == 'content_default_http_proxy' && (::HttpProxy.table_exists? rescue(false))
      proxy = HttpProxy.where(name: value).first

      if proxy
        proxy.update_attribute(:organizations, Organization.unscoped.all)
        proxy.update_attribute(:locations, Location.unscoped.all)
      end
    end
  end

  def content_default_http_proxy
    proxy = HttpProxy.where(name: value).first
    return if proxy || value.blank?

    errors.add(:base, _('There is no such HTTP proxy'))
  end
end

# If the database is not migrated yet, the system will not be able to load
# since setting initializers will try to load old class. Let it have the class and remove it
# later.
if Setting.where(category: 'Setting::Katello').count > 0
  class Setting::Katello < Setting
  end
end
