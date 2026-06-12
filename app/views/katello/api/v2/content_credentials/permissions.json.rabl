collection @content_credentials

if ::Foreman::Cast.to_bool(params.fetch(:include_permissions, false))
  user = User.current # current_user is not available here
  node do
    node(:can_create) { user.can?("create_content_credentials") }
    node(:can_edit) { user.can?("edit_content_credentials") }
    node(:can_delete) { user.can?("destroy_content_credentials") }
    node(:can_view) { user.can?("view_content_credentials") }
  end
end
