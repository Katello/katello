class AddRoleDescription < ActiveRecord::Migration
  def self.up
    add_column :roles, :description, :string, :limit => 250
  end

  def self.down
    remove_column :roles, :description
  end
end
