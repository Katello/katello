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
