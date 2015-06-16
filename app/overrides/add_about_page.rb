# Add Installed Packages to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_installed_packages_to_about",
                     :insert_bottom => '#about',
                     :partial => 'foreman/overrides/about/installed_packages'
                     )

# Add Katello Support information to About page
Deface::Override.new(:virtual_path => "about/index",
                     :name => "add_support_documentation",
                     :insert_bottom => '.col-md-5 .stats-well:first-child',
                     :partial => 'foreman/overrides/about/support_documentation'
                     )
