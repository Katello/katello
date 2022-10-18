Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_tab",
                     :insert_after => 'ul.nav > li:first',
                     :partial => 'overrides/smart_proxies/environment_tab')

Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_tab_pane",
                     :insert_after => 'erb[loud]:contains("render"):contains("taxonomies/loc_org_tabs")',
                     :partial => 'overrides/smart_proxies/environment_tab_pane')

Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_download_policy",
                     :insert_bottom => '#primary',
                     :partial => 'overrides/smart_proxies/download_policy')

Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_acs_http_proxy",
                     :insert_bottom => '#primary',
                     :partial => 'overrides/smart_proxies/acs_http_proxy')
