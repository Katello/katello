class AddSubscriptionAllocated < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :allocated, :integer, :null => false, :default => 0
  end

  def self.down
    drop_column :subscriptions, :allocated
  end
end
