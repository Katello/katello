collection @alternate_content_sources

if params.key?(:include_permissions)
  user = User.current # current_user is not available here
  node do
    node(:can_create) { user.can?("create_alternate_content_sources") }
    node(:can_edit) { user.can?("edit_alternate_content_sources") }
    node(:can_delete) { user.can?("delete_alternate_content_sources") }
  end
end
