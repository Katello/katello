class Setting::Content < Setting
  #rubocop:disable Metrics/MethodLength
  #rubocop:disable Metrics/AbcSize
  def self.load_defaults
    return unless super

    download_policies = proc { Hash[::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.map { |p| [p, p] }] }
    proxy_download_policies = proc { Hash[::SmartProxy::DOWNLOAD_POLICIES.map { |p| [p, p] }] }
    self.transaction do
      [
        self.set('katello_default_provision', N_("Default provisioning template for new Operating Systems"), 'Katello Kickstart Default'),
        self.set('katello_default_finish', N_("Default finish template for new Operating Systems"), 'Katello Kickstart Default Finish'),
        self.set('katello_default_user_data', N_("Default user data for new Operating Systems"), 'Katello Kickstart Default User Data'),
        self.set('katello_default_PXELinux', N_("Default PXElinux template for new Operating Systems"), 'Kickstart default PXELinux'),
        self.set('katello_default_iPXE', N_("Default iPXE template for new Operating Systems"), 'Kickstart default iPXE'),
        self.set('katello_default_ptable', N_("Default partitioning table for new Operating Systems"), 'Kickstart default'),
        self.set('katello_default_kexec', N_("Default kexec template for new Operating Systems"), 'Discovery Red Hat kexec'),
        self.set('katello_default_atomic_provision', N_("Default provisioning template for new Atomic Operating Systems"), 'Katello Atomic Kickstart Default'),
        self.set('content_action_accept_timeout', N_("Time in seconds to wait for a Host to pickup a remote action"), 20),
        self.set('content_action_finish_timeout', N_("Time in seconds to wait for a Host to finish a remote action"), 3600),
        self.set('errata_status_installable', N_("Calculate errata host status based only on errata in a Host's Content View and Lifecycle Environment"), false),
        self.set('restrict_composite_view', N_("If set to true, a composite content view may not be published or "\
                 "promoted, unless the component content view versions that it includes exist in the target environment."), false),
        self.set('pulp_sync_node_action_accept_timeout', N_("Time in seconds to wait for a pulp node to remote action"), 20),
        self.set('pulp_sync_node_action_finish_timeout', N_("Time in seconds to wait for a pulp node to finish sync"), 12.hours.to_i),
        self.set('check_services_before_actions', N_("Whether or not to check the status of backend services such as pulp and candlepin prior to performing some actions."), true),
        self.set('force_post_sync_actions', N_("Force post sync actions such as indexing and email even if no content was available."), false),
        self.set('default_download_policy', N_("Default download policy for repositories (either 'immediate', 'on_demand', or 'background')"), "on_demand",
                 N_('Default Repository download policy'), nil, :collection => download_policies),
        self.set('default_proxy_download_policy', N_("Default download policy for Smart Proxy syncs (either 'inherit', immediate', 'on_demand', or 'background')"), "on_demand",
                 N_('Default Smart Proxy download policy'), nil, :collection => proxy_download_policies),
        self.set('pulp_docker_registry_port', N_("The port used by Pulp Crane to provide Docker Registries"), 5000),
        self.set('pulp_export_destination', N_("On-disk location for exported repositories"), N_("/var/lib/pulp/katello-export")),
        self.set('pulp_client_key', N_("Path for ssl key used for pulp server auth"), "/etc/pki/katello/private/pulp-client.key"),
        self.set('pulp_client_cert', N_("Path for ssl cert used for pulp server auth"), "/etc/pki/katello/certs/pulp-client.crt"),
        self.set('remote_execution_by_default', N_("If set to true, use the remote execution over katello-agent for remote actions"), false),
        self.set('use_pulp_oauth', N_("use oauth authentication for pulp instead of the default cert based authentication"), false),
        self.set('unregister_delete_host', N_("When unregistering host via subscription-manager, also delete server-side host record"), false)
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
