class RemoveDockerRegistryURL < ActiveRecord::Migration[4.2]
  def up
    remove_column :katello_providers, :docker_registry_url
  end

  def down
    add_column :katello_providers, :docker_registry_url, :string, :limit => 255
  end
end
