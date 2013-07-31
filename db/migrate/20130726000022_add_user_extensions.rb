class AddUserExtensions < ActiveRecord::Migration
  def up
    add_column :users, :helptips_enabled, :boolean, :default=>true
    add_column :users, :hidden, :boolean, :default=>false, :null=>false
    add_column :users, :page_size, :integer, :default=>25, :null=>false
    add_column :users, :disabled, :boolean, :default=>false
    add_column :users, :preferences, :text
    add_column :users, :remote_id, :string
    add_column :users, :default_environment_id, :integer, :default=>true
    
    add_index(:users, :remote_id, :unique=>true)
  end

  def down
    remove_column :users, :helptips_enabled
    remove_column :users, :hidden
    remove_column :users, :page_size
    remove_column :users, :disabled
    remove_column :users, :preferences
    remove_column :users, :remote_id
    remove_column :users, :default_environment_id
  end
end

