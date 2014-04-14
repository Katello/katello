# Remove Parent select box from org
Deface::Override.new(:virtual_path => "taxonomies/_step1",
                     :name => "remove_parent_organization_on_create",
                     :remove => 'code[erb-loud]:contains("select_f"):contains(":parent")'
                     )

Deface::Override.new(:virtual_path => "taxonomies/_form",
                     :name => "remove_parent_organization_on_edit",
                     :remove => 'code[erb-loud]:contains("select_f"):contains(":parent")'
                     )

# Add organization attributes to org creation
Deface::Override.new(:virtual_path => "taxonomies/_step1",
                     :name => "add_organization_attributes_on_create",
                     :insert_after => 'code[erb-loud]:contains("text_f"):contains(":name")',
                     :partial => '../overrides/foreman/organizations/step_1_override')

# Add organization attributes to org edit
Deface::Override.new(:virtual_path => "taxonomies/_form",
                     :name => "add_organization_attributes_on_edit",
                     :insert_after => 'code[erb-loud]:contains("text_f"):contains(":name")',
                     :partial => '../overrides/foreman/organizations/edit_override')
