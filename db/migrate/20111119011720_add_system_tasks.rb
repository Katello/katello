class AddSystemTasks < ActiveRecord::Migration
  def self.up
    create_table :system_tasks do |t|
      t.references :system
      t.references :task_status
      t.integer :type_id
    end

    create_table :package_tasks do |t|
      t.references :system_task
      t.references :task_status
      t.string :name
    end
  end

  def self.down
    drop_table :system_tasks
    drop_table :package_tasks
  end
end
