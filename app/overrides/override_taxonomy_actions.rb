# Remove support for organization nesting
Deface::Override.new(:virtual_path => "taxonomies/index",
                     :name => "override_taxonomy_actions",
                     :replace => 'code[erb-loud]:contains("action_buttons")',
                     :partial => '../overrides/foreman/taxonomies/action_buttons'
                    )
