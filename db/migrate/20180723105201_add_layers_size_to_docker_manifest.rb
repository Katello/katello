class AddLayersSizeToDockerManifest < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_docker_manifests, :layers_size, :integer
  end
end
