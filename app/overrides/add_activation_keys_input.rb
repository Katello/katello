Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "add_activation_keys_tab",
                     :insert_after => 'ul.nav > erb[silent]:contains("show_organization_tab?") ~ erb[silent]:contains("end")',
                     :partial => 'overrides/activation_keys/host_tab')

Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "add_activation_keys_tab_pane",
                     :insert_after => 'erb[loud]:contains("render"):contains("taxonomies/loc_org_tabs")',
                     :partial => 'overrides/activation_keys/host_tab_pane')

Deface::Override.new(:virtual_path => "hostgroups/_form",
                     :name => "hostgroups_update_environments_select",
                     :insert_before => 'erb[loud]:contains("compute_resource_id")',
                     :partial => 'overrides/activation_keys/host_environment_select')

Deface::Override.new(:virtual_path => "common/os_selection/_operatingsystem",
                     :name => "hosts_select_media_type",
                     :insert_before => 'erb[loud]:contains("select_f"):contains(":medium_id")',
                     :partial => 'overrides/activation_keys/host_media_type_select')

Deface::Override.new(:virtual_path => "common/os_selection/_operatingsystem",
                     :name => "hosts_select_synced_content",
                     :insert_after => 'erb[loud]:contains("select_f"):contains(":medium_id")',
                     :partial => 'overrides/activation_keys/host_synced_content_select')
