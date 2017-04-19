blueprints = [
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
      ]
    }
  },
  {
    group: N_('Subscriptions'),
    name: 'subs_expire_soon',
    message: N_('%{expiring_subs} subscriptions in %{subject} are going to expire in less than %{days} days. Please renew them before they expire to guarantee your hosts will continue receiving content.'),
    level: 'warning'
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
