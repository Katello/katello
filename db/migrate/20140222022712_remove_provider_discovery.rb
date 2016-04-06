class RemoveProviderDiscovery < ActiveRecord::Migration
  def up
    remove_foreign_key "katello_providers", :name => "providers_discovery_task_id_fk"
    remove_column :katello_providers, :discovery_url
    remove_column :katello_providers, :discovery_task_id
    remove_column :katello_providers, :discovered_repos
  end

  def down
    add_column :katello_providers, :discovery_url, :string, :limit => 255
    add_column :katello_providers, :discovered_repos, :text
    add_column :katello_providers, :discovery_task_id, :integer
    add_foreign_key "katello_providers", "katello_task_statuses", :name => "providers_discovery_task_id_fk", :column => "discovery_task_id"
  end
end
