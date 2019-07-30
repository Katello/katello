collection @subscriptions

if params.key?(:include_permissions)
  node do |resource|
    node(:can_manage_subscription_allocatons) { authorized_for(:auth_object => resource, :authorizer => authorizer, :permission => "manage_subscription_allocations") }
    node(:can_import_manifest) { authorized_for(:auth_object => resource, :authorizer => authorizer, :permission => "import_manifest") }
    node(:can_delete_manifest) { authorized_for(:auth_object => resource, :authorizer => authorizer, :permission => "delete_manifest") }
  end
end
