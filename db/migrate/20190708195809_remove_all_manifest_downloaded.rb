class RemoveAllManifestDownloaded < ActiveRecord::Migration[5.2]
  def up
    remove_column :katello_docker_manifests, :downloaded
    remove_column :katello_docker_manifest_lists, :downloaded
  end

  def down
    add_column :katello_docker_manifests, :downloaded, :boolean
    add_column :katello_docker_manifest_lists, :downloaded, :boolean
  end
end
