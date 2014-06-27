class AddUnlimitedToHostCollection < ActiveRecord::Migration
  def up
    add_column :katello_host_collections, :unlimited_content_hosts, :boolean, :default => true
    change_column :katello_host_collections, :max_content_hosts, :integer, :null => true, :default => nil

    update "UPDATE katello_host_collections
            SET unlimited_content_hosts = true, max_content_hosts = null
            WHERE max_content_hosts = -1"

    update "UPDATE katello_host_collections
            SET unlimited_content_hosts = false
            WHERE max_content_hosts > 0"
  end

  def down
    update "UPDATE katello_host_collections
            SET max_content_hosts = -1
            WHERE unlimited_content_hosts = true"

    remove_column :katello_host_collections, :unlimited_content_hosts
    change_column :katello_host_collections, :max_content_hosts, :integer, :null => false, :default => -1
  end
end
