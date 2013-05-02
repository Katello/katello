class RemoveOwnRoleFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :own_role_id
  end

  def self.down
    add_column :users, :own_role_id, :integer
  end
end
