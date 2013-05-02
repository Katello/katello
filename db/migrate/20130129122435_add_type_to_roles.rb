class AddTypeToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :type, :string
  end

  def self.down
    remove_column :roles, :type
  end
end
