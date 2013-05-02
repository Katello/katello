class AddRolesLock < ActiveRecord::Migration
  def self.up
    add_column :roles, :locked, :boolean, :default => false
  end

  def self.down
    remove_column :roles, :locked
  end
end
