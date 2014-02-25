class RemoveProviderDiscovery < ActiveRecord::Migration
  def up
    remove_column :katello_providers, :discovery_url
    remove_column :katello_providers, :discovery_task_id
    remove_column :katello_providers, :discovered_repos
  end

  def down
    add_column :katello_providers, :discovery_url, :string
    add_column :katello_providers, :discovered_repos, :text
    add_column :katello_providers, :discovery_task_id, :integer
  end
end
