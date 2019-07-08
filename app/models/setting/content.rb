class Setting::Content < Setting
  #rubocop:disable Metrics/MethodLength
  #rubocop:disable Metrics/AbcSize

  def self.hashify_parameters(parameters)
    Hash[parameters.map { |p| [p, p] }]
  end

  def self.load_defaults
    return unless super

    BLANK_ATTRS.concat %w(register_hostname_fact default_location_subscribed_hosts
                          default_location_puppet_content)

    download_policies = proc { hashify_parameters(::Runcible::Models::YumImporter::DOWNLOAD_POLICIES) }
    proxy_download_policies = proc { hashify_parameters(::SmartProxy::DOWNLOAD_POLICIES) }
    dependency_solving_options = proc { hashify_parameters(['conservative', 'greedy']) }

    self.transaction do
      [
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
                ),
        self.set('katello_default_kexec', N_("Default kexec template for new Operating Systems created from synced content"),
                 'Discovery Red Hat kexec', N_('Default synced OS kexec template'),
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
        self.set('content_disconnected', N_("A server operating in disconnected mode does not communicate with the Red Hat CDN."),
                 false, N_('Disconnected mode')),
        self.set('errata_status_installable', N_("Calculate errata host status based only on errata in a Host's Content View and Lifecycle Environment"),
                 false, N_('Installable errata from Content View')),
        self.set('restrict_composite_view', N_("If set to true, a composite content view may not be published or "\
                 "promoted, unless the component content view versions that it includes exist in the target environment."),
                 false, N_('Restrict Composite Content View promotion')),
        self.set('check_services_before_actions', N_("Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions."),
                 true, N_('Check services before actions')),
        self.set('foreman_proxy_content_auto_sync', N_("Whether or not to auto sync the Smart Proxies after a Content View promotion."),
                 true, N_('Sync Smart Proxies after Content View promotion')),
        self.set('default_download_policy', N_("Default download policy for repositories (either 'immediate', 'on_demand', or 'background')"), "on_demand",
                 N_('Default Repository download policy'), nil, :collection => download_policies),
        self.set('default_proxy_download_policy', N_("Default download policy for Smart Proxy syncs (either 'inherit', immediate', 'on_demand', or 'background')"), "on_demand",
                 N_('Default Smart Proxy download policy'), nil, :collection => proxy_download_policies),
        self.set('pulp_docker_registry_port', N_("The port used by Pulp Crane to provide Docker Registries"),
                 5000, N_('Pulp Docker registry port')),
        self.set('pulp_export_destination', N_("On-disk location for exported repositories"),
                 "/var/lib/pulp/katello-export", N_('Pulp export destination filepath')),
        self.set('pulp_client_key', N_("Path for ssl key used for pulp server auth"),
                 "/etc/pki/katello/private/pulp-client.key", N_('Pulp client key')),
        self.set('pulp_client_cert', N_("Path for ssl cert used for pulp server auth"),
                 "/etc/pki/katello/certs/pulp-client.crt", N_('Pulp client cert')),
        self.set('remote_execution_by_default', N_("If set to true, use the remote execution over katello-agent for remote actions"),
                 false, N_('Use remote execution by default')),
        self.set('unregister_delete_host', N_("When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host " \
                                              "such as virtual machines and DNS records may also be deleted."),
                 false, N_('Delete Host upon unregister')),
        self.set('register_hostname_fact', N_("When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')"),
                 '', N_('Subscription manager name registration fact'), nil),
        self.set('register_hostname_fact_strict_match', N_('If true, and register_hostname_fact is set and provided, registration will look for a new host by name only '\
                  'using that fact, and will skip all hostname matching'), false, N_('Subscription manager name registration fact strict matching'), nil),
        self.set('erratum_install_batch_size', N_("Errata installed via katello-agent will be triggered in batches of this size. Set to 0 to install all errata in one batch."),
                 0, N_('Erratum Install Batch Size')),
        self.set('default_location_subscribed_hosts',
                 N_('Default Location where new subscribed hosts will put upon registration'),
                 nil, N_('Default Location subscribed hosts'), nil,
                 :collection => proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] }),
        self.set('default_location_puppet_content',
                 N_('Default Location where new Puppet content will be put upon Content View publish'),
                 nil, N_('Default Location Puppet content'), nil,
                 :collection => proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] }),
        self.set('host_update_lock', N_("Allow multiple concurrent Actions::Katello::Host::Update calls for one host to be processed at the same time."),
                 false, N_('Concurrent Actions::Katello::Host::Update allowed')),
        self.set('expire_soon_days', N_('The number of days remaining in a subscription before you will be reminded about renewing it.'),
                 120, N_('Expire soon days')),
        self.set('content_view_solve_dependencies',
                 N_('The default dependency solving value for new Content Views.'),
                 false, N_('Content View Dependency Solving Default')),
        self.set('dependency_solving_algorithm',
                 N_("How the logic of solving dependencies in a Content View is managed. Conservative will only add " \
                 "packages to solve the dependencies if the packaged needed doesn't exist. Greedy will pull in the " \
                 "latest package to solve a dependency even if it already does exist in the repository."),
                 'conservative', N_('Content View Dependency Solving Algorithm'), nil,
                 :collection => dependency_solving_options)
      ].each { |s| self.create! s.update(:category => "Setting::Content") }
    end
    true
  end

  def self.katello_template_setting_values(name)
    templates = ProvisioningTemplate.where(:template_kind => TemplateKind.where(:name => name))
    templates.each_with_object({}) { |tmpl, hash| hash[tmpl.name] = tmpl.name }
  end
end

# If the database is not migrated yet, the system will not be able to load
# since setting initializers will try to load old class. Let it have the class and remove it
# later.
if Setting.where(category: 'Setting::Katello').count > 0
  class Setting::Katello < Setting
  end
end
