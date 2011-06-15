class AddUserPageSize < ActiveRecord::Migration
  def self.up
    add_column :users, :page_size, :integer, :null=>false, :default=>25
  end

  def self.down
    remove_column :users, :page_size
  end
end
