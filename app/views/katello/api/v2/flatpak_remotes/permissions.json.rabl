collection @flatpak_remotes

if ::Foreman::Cast.to_bool(params.fetch(:include_permissions, false))
  user = User.current # current_user is not available here
  node do
    node(:can_create) { user.can?("create_flatpak_remotes") }
    node(:can_edit) { user.can?("edit_flatpak_remotes") }
    node(:can_delete) { user.can?("destroy_flatpak_remotes") }
    node(:can_view) { user.can?("view_flatpak_remotes") }
  end
end
