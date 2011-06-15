class AddOwnerToRole < ActiveRecord::Migration
  def self.up
    add_column :users, :own_role_id, :integer
  end

  def self.down
    remove_column :users, :own_role_id
  end
end
