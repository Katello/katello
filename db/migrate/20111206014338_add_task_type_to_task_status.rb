class AddTaskTypeToTaskStatus < ActiveRecord::Migration
  def self.up
    add_column :task_statuses, :task_type, :string
  end

  def self.down
    remove_column :task_statuses, :task_type
  end
end
