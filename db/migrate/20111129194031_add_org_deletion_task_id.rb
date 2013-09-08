class AddOrgDeletionTaskId < ActiveRecord::Migration
  def self.up
    add_column :organizations, :task_id, :integer, :default => nil
  end

  def self.down
    remove_column :organizations, :task_id
  end
end
