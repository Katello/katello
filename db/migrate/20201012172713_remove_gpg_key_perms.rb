class RemoveGpgKeyPerms < ActiveRecord::Migration[6.0]
  def permission_map
    {
      Permission.find_by(name: :view_gpg_keys) => Permission.find_by(name: :view_content_credentials),
      Permission.find_by(name: :edit_gpg_keys) => Permission.find_by(name: :edit_content_credentials),
      Permission.find_by(name: :destroy_gpg_keys) => Permission.find_by(name: :destroy_content_credentials),
      Permission.find_by(name: :create_gpg_keys) => Permission.find_by(name: :create_content_credentials),
    }
  end

  def up
    perms = permission_map
    perms.each do |old_perm, new_perm|
      Filtering.where(permission_id: old_perm.id).update_all(:permission_id => new_perm.id) if old_perm
    end
    names = perms.keys.compact.map(&:name)
    Permission.where(:name => names).destroy_all if names.any?
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
