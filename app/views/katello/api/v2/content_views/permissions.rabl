collection @content_views

if params.key?(:include_permissions)
  user = User.current # current_user is not available here
  node do
    node(:can_create) { user.can?("create_content_views") }
    node(:can_view) { user.can?("view_content_views") }
  end
end
