collection @subscriptions

if params.key?(:include_permissions)
  user = User.current # current_user is not available here
  node do
    node(:can_manage_subscription_allocations) { user.can?("manage_subscription_allocations") }
    node(:can_import_manifest) { user.can?("import_manifest") }
    node(:can_delete_manifest) { user.can?("delete_manifest") }
    node(:can_edit_organizations) { user.can?("edit_organizations") }
  end
end
