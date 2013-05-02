class RenameKeyPoolSubscriptionId < ActiveRecord::Migration
  def self.up
    rename_column :key_pools, :subscription_id, :pool_id
  end

  def self.down
    rename_column :key_pools, :pool_id, :subscription_id
  end
end
