# seeds UI notification blueprints that are supported by Content View.
[
  {
    group: N_('Content View'),
    name: 'content_view_auto_publish_error',
    message: N_('Composite Content View \'%{subject}\' failed auto-publish'),
    level: 'error',
    actions:
    {
      links:
      [
      ]
    }
  }
].each { |blueprint| UINotifications::Seed.new(blueprint).configure }
