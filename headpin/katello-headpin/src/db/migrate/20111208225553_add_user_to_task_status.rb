class AddUserToTaskStatus < ActiveRecord::Migration
  def self.up
    user_id = User.find_by_username("admin").nil? ? 0 : User.find_by_username("admin").id
    add_column :task_statuses, :user_id, :integer, :null => false, :default => user_id
  end

  def self.down
    remove_column :task_statuses, :user_id
  end
end
