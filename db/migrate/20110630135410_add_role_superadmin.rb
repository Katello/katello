class AddRoleSuperadmin < ActiveRecord::Migration
  def self.up
    add_column :roles, :superadmin, :boolean, :default => false
  end

  def self.down
    remove_column :roles, :superadmin
  end
end
