class RemoveUserFields < ActiveRecord::Migration[4.2]
  def up
    remove_column :users, :helptips_enabled
    remove_column :users, :page_size
    remove_column :users, :preferences
    remove_column :users, :remote_id
  end

  def down
    add_column :users, :helptips_enabled, :boolean, :default => true
    add_column :users, :hidden, :boolean, :default => false, :null => false
    add_column :users, :page_size, :integer, :default => 25, :null => false
    add_column :users, :preferences, :text
    add_column :users, :remote_id, :string, :limit => 255
  end
end
