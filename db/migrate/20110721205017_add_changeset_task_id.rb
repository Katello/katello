class AddChangesetTaskId < ActiveRecord::Migration
  def self.up
    change_table :changesets do |t|
      t.references :task_status
    end
  end

  def self.down
  end
end
