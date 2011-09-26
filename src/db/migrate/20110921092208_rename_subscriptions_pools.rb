class RenameSubscriptionsPools < ActiveRecord::Migration
  def self.up
    rename_table :subscriptions, :pools
  end

  def self.down
    rename_table :pools, :subscriptions
  end
end
