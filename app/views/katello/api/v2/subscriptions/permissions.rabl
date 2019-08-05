collection @subscriptions

if params.key?(:include_permissions)
  node do |resource|
    node(:can_manage_subscription_allocations) { current_user.can?("manage_subscription_allocations") }
    node(:can_import_manifest) { current_user.can?("import_manifest") }
    node(:can_delete_manifest) { current_user.can?("delete_manifest") }
    node(:can_edit_organizations) { current_user.can?("edit_organizations") }
  end
end
