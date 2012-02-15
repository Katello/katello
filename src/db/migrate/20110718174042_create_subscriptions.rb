class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.string :subscription, :null => false
      t.timestamps
    end

    create_table :key_subscriptions do |t|
      t.references :activation_key
      t.references :subscription
      t.integer :allocated, :null => false, :default => 0
    end
  end

  def self.down
    drop_table :key_subscriptions
    drop_table :subscriptions
  end
end
