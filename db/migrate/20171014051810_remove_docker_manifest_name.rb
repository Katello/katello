class RemoveDockerManifestName < ActiveRecord::Migration[4.2]
  def up
    remove_column :katello_docker_manifests, :name
  end

  def down
    add_column :katello_docker_manifests, :name, :string, :limit => 255
  end
end
