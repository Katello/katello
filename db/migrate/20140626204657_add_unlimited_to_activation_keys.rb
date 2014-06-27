class AddUnlimitedToActivationKeys < ActiveRecord::Migration
  def up
    add_column :katello_activation_keys, :unlimited_content_hosts, :boolean, :default => true
    rename_column :katello_activation_keys, :usage_limit, :max_content_hosts
    change_column_default :katello_activation_keys, :max_content_hosts, nil

    update "UPDATE katello_activation_keys
            SET unlimited_content_hosts = true, max_content_hosts = null
            WHERE max_content_hosts = -1"

    update "UPDATE katello_activation_keys
            SET unlimited_content_hosts = false
            WHERE max_content_hosts > 0"
  end

  def down
    update "UPDATE katello_activation_keys
            SET max_content_hosts = -1
            WHERE unlimited_content_hosts = true"

    remove_column :katello_activation_keys, :unlimited_content_hosts
    rename_column :katello_activation_keys, :max_content_hosts, :usage_limit
    change_column_default :katello_activation_keys, :usage_limit, -1
  end
end
