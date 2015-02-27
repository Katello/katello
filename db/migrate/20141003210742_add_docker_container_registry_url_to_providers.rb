class AddDockerContainerRegistryUrlToProviders < ActiveRecord::Migration
  def up
    add_column :katello_providers, :docker_registry_url, :string
  end

  def down
    remove_column :katello_providers, :docker_registry_url
  end
end
