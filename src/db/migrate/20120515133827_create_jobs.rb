class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.references :job_owner, :polymorphic => true
      t.string :pulp_id, :null=>false
    end

    create_table :job_tasks do |t|
      t.references :job
      t.references :task_status
    end
  end

  def self.down
    drop_table :job_tasks
    drop_table :jobs
  end
end
