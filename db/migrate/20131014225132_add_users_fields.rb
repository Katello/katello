class AddUsersFields < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :helptips_enabled, :boolean, :default => true
    add_column :users, :hidden, :boolean, :default => false, :null => false
    add_column :users, :page_size, :integer, :default => 25, :null => false
    add_column :users, :preferences, :text
    add_column :users, :remote_id, :string, :limit => 255
  end
end
