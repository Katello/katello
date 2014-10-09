class RemoveDelayedJobs < ActiveRecord::Migration
  def up
    drop_table "delayed_jobs"
  end

  def down
    create_table "delayed_jobs", :force => true do |t|
      t.integer "priority",   :default => 0
      t.integer "attempts",   :default => 0
      t.text "handler"
      t.text "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.datetime "created_at",                :null => false
      t.datetime "updated_at",                :null => false
      t.string "queue"
    end

    add_index "delayed_jobs", %w(priority run_at), :name => "delayed_jobs_priority"
  end
end
