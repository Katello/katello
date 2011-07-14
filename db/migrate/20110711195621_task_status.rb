class TaskStatus < ActiveRecord::Migration
  def self.up
    create_table :task_statuses do |t|
      t.references :organization, :null => false
      t.string :uuid, :null => false
      t.string :state
      t.text :result
      t.datetime :start_time
      t.datetime :finish_time
      t.string :remote_system
      t.timestamps
    end
    add_index :task_statuses, :uuid
  end

  def self.down
    remove_index :task_statuses, :uuid
    drop_table :task_statuses
  end
end
