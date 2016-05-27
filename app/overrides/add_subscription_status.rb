# Add link to content-host on the host show page
Deface::Override.new(:virtual_path => "hosts/show",
                     :name => "add_system_link_to_host",
                     :insert_bottom => 'td:first',
                     :partial => 'overrides/hosts/subscription_link'
                    )
