class AddManifestRefreshedAtToOrganization < ActiveRecord::Migration[5.1]
  def up
    add_column(:taxonomies, :manifest_refreshed_at, :datetime)
  end

  def down
    remove_column(:taxonomies, :manifest_refreshed_at)
  end
end
