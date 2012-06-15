class AddTaskOwnerToTaskStatus < ActiveRecord::Migration
  def self.up
    change_table :task_statuses do |t|
      t.references :task_owner, :polymorphic => true
    end

    execute("UPDATE task_statuses t
             SET task_owner_type = 'System', task_owner_id = s.system_id
             FROM system_tasks s
             WHERE s.task_status_id = t.id;")

    drop_table :system_tasks
  end

  def self.down
    create_table :system_tasks do |t|
      t.references :system
      t.references :task_status
    end

    execute("INSERT INTO system_tasks (task_status_id, system_id)
            SELECT id, task_owner_id
            FROM task_statuses
            WHERE task_statuses.task_owner_type = 'System'")

    change_table :task_statuses do |t|
      t.remove_references :task_owner, :polymorphic => true
    end
  end
end
