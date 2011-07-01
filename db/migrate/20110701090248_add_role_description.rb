class AddRoleDescription < ActiveRecord::Migration
  def self.up
    add_column :roles, :description, :text, :limit => 2048
  end

  def self.down
    remove_column :roles, :description
  end
end
