# Add content-host status to the host show page
Deface::Override.new(:virtual_path => "hosts/_overview",
                     :name => "add_system_status_to_host",
                     :insert_after => 'tr:first',
                     :partial => '../overrides/foreman/hosts/subscription_status'
)

# Add link to content-host on the host show page
Deface::Override.new(:virtual_path => "hosts/show",
                     :name => "add_system_link_to_host",
                     :insert_bottom => 'td:first',
                     :partial => '../overrides/foreman/hosts/subscription_link'
)
