class RemoveJobs < ActiveRecord::Migration
  def up
    drop_table :katello_job_tasks
    drop_table :katello_jobs
  end

  def down
    create_table "katello_job_tasks", force: :cascade do |t|
      t.integer "job_id"
      t.integer "task_status_id"
    end

    add_index "katello_job_tasks", ["job_id"], name: "index_job_tasks_on_job_id", using: :btree
    add_index "katello_job_tasks", ["task_status_id"], name: "index_job_tasks_on_task_status_id", using: :btree

    create_table "katello_jobs", force: :cascade do |t|
      t.integer "job_owner_id"
      t.string  "job_owner_type", limit: 255
      t.string  "pulp_id",        limit: 255, null: false
    end

    add_index "katello_jobs", ["job_owner_id"], name: "index_jobs_on_job_owner_id", using: :btree
    add_index "katello_jobs", ["pulp_id"], name: "index_jobs_on_pulp_id", using: :btree
  end
end
