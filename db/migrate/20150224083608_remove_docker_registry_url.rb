class RemoveDockerRegistryUrl < ActiveRecord::Migration
  def up
    remove_column :katello_providers, :docker_registry_url
  end

  def down
    add_column :katello_providers, :docker_registry_url, :string
  end
end
