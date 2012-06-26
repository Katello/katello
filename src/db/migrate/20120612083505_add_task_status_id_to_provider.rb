class AddTaskStatusIdToProvider < ActiveRecord::Migration
  def self.up
    change_table :providers do |t|
      t.references :task_status
    end
  end

  def self.down
    change_table :providers do |t|
      t.remove :task_status_id
    end
  end
end

