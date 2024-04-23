class AddFieldsToKatelloDockerManifest < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_docker_manifests, :annotations, :jsonb, default: {}
    add_column :katello_docker_manifests, :labels, :jsonb, default: {}
    add_column :katello_docker_manifests, :is_bootable, :boolean, default: false
    add_column :katello_docker_manifests, :is_flatpak, :boolean, default: false
  end
end
