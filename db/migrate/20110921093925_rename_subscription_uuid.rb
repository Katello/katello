class RenameSubscriptionUuid < ActiveRecord::Migration
  def self.up
    rename_column :pools, :subscription, :cp_id
  end

  def self.down
    rename_column :pools, :cp_id, :subscription
  end
end
