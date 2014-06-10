Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_tab",
                     :insert_after => 'ul.nav > li:first',
                     :partial => '../overrides/foreman/smart_proxies/environment_tab')

Deface::Override.new(:virtual_path => "smart_proxies/_form",
                     :name => "add_smart_proxies_tab_pane",
                     :insert_after => 'code[erb-loud]:contains("render"):contains("taxonomies/loc_org_tabs")',
                     :partial => '../overrides/foreman/smart_proxies/environment_tab_pane')
