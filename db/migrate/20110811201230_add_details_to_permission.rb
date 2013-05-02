class AddDetailsToPermission < ActiveRecord::Migration
  def self.up
    add_column :permissions, :name, :string, :default => ""
    add_column :permissions, :description, :string, :default => ""
  end

  def self.down
    remove_column :permissions, :description
    remove_column :permissions, :name
  end
end
