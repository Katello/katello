# Add Installed Packages to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_installed_packages_to_about",
                     :insert_bottom => '#about',
                     :partial => 'overrides/about/installed_packages'
                    )
