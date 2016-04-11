class ChangeActivationKeyColumnNames < ActiveRecord::Migration
  def self.up
    rename_column :katello_activation_keys, :max_content_hosts, :max_hosts
    rename_column :katello_activation_keys, :unlimited_content_hosts, :unlimited_hosts
  end

  def self.down
    rename_column :katello_activation_keys, :max_hosts, :max_content_hosts
    rename_column :katello_activation_keys, :unlimited_hosts, :unlimited_content_hosts
  end
end
