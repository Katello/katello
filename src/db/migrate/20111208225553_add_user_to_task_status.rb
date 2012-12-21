class AddUserToTaskStatus < ActiveRecord::Migration
  def self.up
    user = User.find_by_hidden(true)
    user_id = user.nil? ? 0 : user.id
    add_column :task_statuses, :user_id, :integer, :null => false, :default => user_id
  end
  
  def self.down
    remove_column :task_statuses, :user_id
  end
end