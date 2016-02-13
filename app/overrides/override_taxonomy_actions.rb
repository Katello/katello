# Remove support for organization nesting
Deface::Override.new(:virtual_path => "taxonomies/index",
                     :name => "override_taxonomy_actions",
                     :replace => 'erb[loud]:contains("action_buttons")',
                     :partial => 'overrides/taxonomies/action_buttons'
                    )
