class AddDefaultEnvironmentToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :default_environment_id, :integer
  end

  def self.down
    remove_column :users, :default_environment_id
  end
end
