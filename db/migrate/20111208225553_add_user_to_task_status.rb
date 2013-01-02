class AddUserToTaskStatus < ActiveRecord::Migration
  def self.up
    user_id = 0
    add_column :task_statuses, :user_id, :integer, :null => false, :default => user_id
  end

  def self.down
    remove_column :task_statuses, :user_id
  end
end
