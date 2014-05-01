# Add System Status to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_system_status_to_about",
                     :insert_bottom => '#about',
                     :partial => '../overrides/foreman/about/system_status'
                     )

# Add Installed Packages to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_installed_packages_to_about",
                     :insert_bottom => '#about',
                     :partial => '../overrides/foreman/about/installed_packages'
                     )

# Add Katello Support information to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_support_documentation",
                     :insert_bottom => '.col-md-5 .stats-well:first-child',
                     :partial => '../overrides/foreman/about/support_documentation'
                     )
