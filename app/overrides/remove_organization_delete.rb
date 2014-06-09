# TODO: ORG_DESTROY - temporarily remove the org destroy link
Deface::Override.new(:virtual_path => "taxonomies/index",
                     :name => "remove_organization_delete",
                     :replace => 'code[erb-loud]:contains("action_buttons")',
                     :partial => '../overrides/foreman/taxonomies/action_buttons'
                    )
