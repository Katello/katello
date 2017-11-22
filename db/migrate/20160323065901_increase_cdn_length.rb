class IncreaseCdnLength < ActiveRecord::Migration[4.2]
  def up
    change_column :katello_providers, :repository_url, :string, :limit => 1024
    change_column :katello_repositories, :url, :string, :limit => 1024
  end

  def down
    change_column :katello_providers, :repository_url, :string, :limit => 255
    change_column :katello_repositories, :url, :string, :limit => 255
  end
end
