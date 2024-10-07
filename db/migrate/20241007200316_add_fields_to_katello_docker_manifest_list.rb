class AddFieldsToKatelloDockerManifestList < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_docker_manifest_lists, :annotations, :jsonb, default: {}
    add_column :katello_docker_manifest_lists, :labels, :jsonb, default: {}
    add_column :katello_docker_manifest_lists, :is_bootable, :boolean, default: false
    add_column :katello_docker_manifest_lists, :is_flatpak, :boolean, default: false
  end
end
