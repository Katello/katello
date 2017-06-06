class ProviderAddRepoGeneration < ActiveRecord::Migration
  def self.up
    add_column :providers, :discovery_url, :string
    add_column :providers, :discovered_repos, :text
  end

  def self.down
    remove_column :providers, :discovery_url
    remove_column :providers, :discovered_repos
  end
end
