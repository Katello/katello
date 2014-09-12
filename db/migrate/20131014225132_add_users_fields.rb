class AddUsersFields < ActiveRecord::Migration
  def change
    add_column :users, :helptips_enabled, :boolean, :default => true
    add_column :users, :hidden, :boolean, :default => false, :null => false
    add_column :users, :page_size, :integer, :default => 25, :null => false
    add_column :users, :disabled, :boolean, :default => false
    add_column :users, :preferences, :text
    add_column :users, :remote_id, :string
  end
end
