class RenameKeySubscrptionKeyPool < ActiveRecord::Migration
  def self.up
    rename_table :key_subscriptions, :key_pools
  end

  def self.down
    rename_table :key_pools, :key_subscriptions
  end
end
