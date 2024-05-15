class AddDockerContainerRegistryURLToProviders < ActiveRecord::Migration[4.2]
  def up
    add_column :katello_providers, :docker_registry_url, :string, :limit => 255
  end

  def down
    remove_column :katello_providers, :docker_registry_url
  end
end
