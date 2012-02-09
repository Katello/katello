class AddParamsToTaskStatus < ActiveRecord::Migration
  def self.up
    add_column :task_statuses, :parameters, :text
  end

  def self.down
    remove_column :task_statuses, :parameters
  end
end
