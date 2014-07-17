Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "add_activation_keys_tab",
                     :insert_after => 'ul.nav > code[erb-silent]:contains("show_organization_tab?") ~ code[erb-silent]:contains("end")',
                     :partial => '../overrides/foreman/activation_keys/host_tab')

Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "add_activation_keys_tab_pane",
                     :insert_after => 'code[erb-loud]:contains("render"):contains("taxonomies/loc_org_tabs")',
                     :partial => '../overrides/foreman/activation_keys/host_tab_pane')

Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "hostgroups_update_environments_select",
                     :insert_before => 'code[erb-loud]:contains("select_f"):contains(":environment_id")',
                     :partial => '../overrides/foreman/activation_keys/host_environment_select')

Deface::Override.new(:virtual_path => "hosts/_form",
                     :name => "hosts_update_environments_select",
                     :insert_before => 'code[erb-loud]:contains("select_f"):contains(":environment_id")',
                     :partial => '../overrides/foreman/activation_keys/host_environment_select')
