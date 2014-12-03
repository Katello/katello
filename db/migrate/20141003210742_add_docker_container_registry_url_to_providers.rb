class AddDockerContainerRegistryUrlToProviders < ActiveRecord::Migration
  def up
    add_column :katello_providers, :docker_registry_url, :string
    ::Katello::Provider.redhat.update_all(:docker_registry_url =>
                                          Katello.config.redhat_docker_registry_url)
  end

  def down
    remove_column :katello_providers, :docker_registry_url
  end
end
