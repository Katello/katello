blueprints = [
  {
    group: N_('Hosts'),
    name: 'host_lifecycle_expire_soon',
    message: N_('%{release}: %{number_of_hosts} hosts are approaching end of %{lifecycle} on %{end_date}. Please upgrade them before support expires. Check Report Host - Statuses for detail.'),
    level: 'warning',
  },
  {
    group: N_('Proxies'),
    name: 'pulp_low_disk_space',
    message: _("%{subject}'s disk is %{percentage} full. Since this proxy is running Pulp, it needs disk space to publish content views. Please ensure the disk does not get full."),
    level: 'warning',
    actions:
    {
      links:
      [
        path_method: :smart_proxy_path,
        title: N_('Details')
      ],
    },
  },
  {
    group: N_('Subscriptions'),
    name: 'subs_expire_soon',
    message: N_('%{expiring_subs} subscriptions in %{subject} are going to expire in less than %{days} days. Please renew them before they expire to guarantee your hosts will continue receiving content.'),
    level: 'warning',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_expire_soon_warning',
    message: N_('Manifest in organization %{subject} has an identity certificate that will expire in %{days_remaining} days, on %{manifest_expire_date}. To extend the expiration date, please refresh your manifest.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_expired_warning',
    message: N_('The manifest imported within Organization %{subject} is no longer valid. Please import a new manifest.'),
    level: 'warning',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_import_success',
    message: N_('Manifest in \'%{subject}\' imported.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_import_error',
    message: N_('Importing manifest into \'%{subject}\' failed.'),
    level: 'error',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_refresh_success',
    message: N_('Manifest in \'%{subject}\' refreshed.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_refresh_error',
    message: N_('Manifest in \'%{subject}\' failed to refresh.'),
    level: 'error',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_delete_success',
    message: N_('Manifest in \'%{subject}\' deleted.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'manifest_delete_error',
    message: N_('Deleting manifest in \'%{subject}\' failed.'),
    level: 'error',
  },
  {
    group: N_('Subscriptions'),
    name: 'sca_enable_success',
    message: N_('Simple Content Access has been enabled for \'%{subject}\'.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'sca_enable_error',
    message: N_('Enabling Simple Content Access failed for \'%{subject}\'.'),
    level: 'error',
  },
  {
    group: N_('Subscriptions'),
    name: 'sca_disable_success',
    message: N_('Simple Content Access has been disabled for \'%{subject}\'.'),
    level: 'info',
  },
  {
    group: N_('Subscriptions'),
    name: 'sca_disable_error',
    message: N_('Disabling Simple Content Access failed for \'%{subject}\'.'),
    level: 'error',
  },
  {
    group: N_('System Status'),
    name: 'system_status_error',
    message: N_('Some services are not properly started. See the About page for more information.'),
    level: 'error',
    actions: {
      links: [
        path_method: :about_index_path,
        title: N_('About page')
      ],
    },
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
