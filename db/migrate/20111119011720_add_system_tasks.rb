class AddSystemTasks < ActiveRecord::Migration
  def self.up
    create_table :system_tasks do |t|
      t.references :system
      t.references :task_status
    end
  end

  def self.down
    drop_table :system_tasks
  end
end
