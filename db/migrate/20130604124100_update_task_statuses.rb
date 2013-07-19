class UpdateTaskStatuses < ActiveRecord::Migration
  def self.up
    change_column :task_statuses, :organization_id, :integer, :null => true
  end

  def self.down
    change_column :task_statuses, :organization_id, :integer, :null => false
  end
end
