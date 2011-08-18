class AddUserToActivationKeys < ActiveRecord::Migration
  def self.up
    add_column :activation_keys, :user_id, :integer
    add_index :activation_keys, :user_id
  end

  def self.down
    remove_index :activation_keys, :user_id
    remove_column :activation_keys, :user_id
  end
end
