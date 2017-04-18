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
  }
]

blueprints.each { |blueprint| UINotifications::Seed.new(blueprint).configure }
