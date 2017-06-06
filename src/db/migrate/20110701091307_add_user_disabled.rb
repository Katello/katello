class AddUserDisabled < ActiveRecord::Migration
  def self.up
    add_column :users, :disabled, :boolean, :default => false
  end

  def self.down
    remove_column :users, :disabled
  end
end
