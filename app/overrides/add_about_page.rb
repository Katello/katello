# Add System Status to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_system_status_to_about",
                     :insert_bottom => '#about',
                     :partial => 'overrides/about/system_status'
                    )

# Add Installed Packages to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_installed_packages_to_about",
                     :insert_bottom => '#about',
                     :partial => 'overrides/about/installed_packages'
                    )
