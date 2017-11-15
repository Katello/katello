class Setting::Content < Setting
  #rubocop:disable Metrics/MethodLength
  #rubocop:disable Metrics/AbcSize
  def self.load_defaults
    return unless super

    BLANK_ATTRS.concat %w(register_hostname_fact default_location_subscribed_hosts
                          default_location_puppet_content)

    download_policies = proc { Hash[::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.map { |p| [p, p] }] }
    proxy_download_policies = proc { Hash[::SmartProxy::DOWNLOAD_POLICIES.map { |p| [p, p] }] }

    self.transaction do
      [
        self.set('katello_default_provision', N_("Default provisioning template for Operating Systems created from synced content"),
                 'Katello Kickstart Default', N_('Default synced OS provisioning template')),
        self.set('katello_default_finish', N_("Default finish template for new Operating Systems created from synced content"),
                 'Katello Kickstart Default Finish', N_('Default synced OS finish template')),
        self.set('katello_default_user_data', N_("Default user data for new Operating Systems created from synced content"),
                 'Katello Kickstart Default User Data', N_('Default synced OS user-data')),
        self.set('katello_default_PXELinux', N_("Default PXElinux template for new Operating Systems created from synced content"),
                 'Kickstart default PXELinux', N_('Default synced OS PXELinux template')),
        self.set('katello_default_iPXE', N_("Default iPXE template for new Operating Systems created from synced content"),
                 'Kickstart default iPXE', N_('Default synced OS iPXE template')),
        self.set('katello_default_ptable', N_("Default partitioning table for new Operating Systems created from synced content"),
                 'Kickstart default', N_('Default synced OS partition table')),
        self.set('katello_default_kexec', N_("Default kexec template for new Operating Systems created from synced content"),
                 'Discovery Red Hat kexec', N_('Default synced OS kexec template')),
        self.set('katello_default_atomic_provision', N_("Default provisioning template for new Atomic Operating Systems created from synced content"),
                 'Katello Atomic Kickstart Default', N_('Default synced OS Atomic template')),
        self.set('manifest_refresh_timeout', N_('Timeout when refreshing a manifest (in seconds)'), 60 * 20, N_("Manifest refresh timeout")),
        self.set('content_action_accept_timeout', N_("Time in seconds to wait for a Host to pickup a remote action"),
                 20, N_('Accept action timeout')),
        self.set('content_action_finish_timeout', N_("Time in seconds to wait for a Host to finish a remote action"),
                 3600, N_('Finish action timeout')),
        self.set('errata_status_installable', N_("Calculate errata host status based only on errata in a Host's Content View and Lifecycle Environment"),
                 false, N_('Installable errata from Content View')),
        self.set('restrict_composite_view', N_("If set to true, a composite content view may not be published or "\
                 "promoted, unless the component content view versions that it includes exist in the target environment."),
                 false, N_('Restrict Composite Content View promotion')),
        self.set('check_services_before_actions', N_("Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions."),
                 true, N_('Check services before actions')),
        self.set('force_post_sync_actions', N_("Force post sync actions such as indexing and email even if no content was available."),
                 false, N_('Force post-sync actions')),
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
        self.set('use_pulp_oauth', N_("use oauth authentication for pulp instead of the default cert based authentication"),
                 false, N_('Use Pulp OAuth authentication')),
        self.set('unregister_delete_host', N_("When unregistering a host via subscription-manager, also delete the host record. Managed resources linked to host " \
                                              "such as virtual machines and DNS records may also be deleted."),
                 false, N_('Delete Host upon unregister')),
        self.set('register_hostname_fact', N_("When registering a host via subscription-manager, force use the specified fact (in the form of 'fact.fact')"),
                 '', N_('Subscription manager name registration fact'), nil),
        self.set('erratum_install_batch_size', N_("Errata installed via katello-agent will be triggered in batches of this size. Set to 0 to install all errata in one batch."),
                 0, N_('Erratum Install Batch Size')),
        self.set('default_location_subscribed_hosts',
                 N_('Default Location where new subscribed hosts will put upon registration'),
                 nil, N_('Default Location subscribed hosts'), nil,
                 :collection => proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] }),
        self.set('default_location_puppet_content',
                 N_('Default Location where new Puppet content will be put upon Content View publish'),
                 nil, N_('Default Location Puppet content'), nil,
                 :collection => proc { Hash[Location.unscoped.all.map { |loc| [loc[:title], loc[:title]] }] })
      ].each { |s| self.create! s.update(:category => "Setting::Content") }
    end
    true
  end
end

# If the database is not migrated yet, the system will not be able to load
# since setting initializers will try to load old class. Let it have the class and remove it
# later.
if Setting.where(category: 'Setting::Katello').count > 0
  class Setting::Katello < Setting
  end
end
