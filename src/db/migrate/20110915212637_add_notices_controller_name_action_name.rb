class AddNoticesControllerNameActionName < ActiveRecord::Migration
  def self.up
    add_column :notices, :controller_name, :string
    add_column :notices, :action_name, :string
  end

  def self.down
    remove_column :notices, :controller_name
    remove_column :notices, :action_name
  end
end
