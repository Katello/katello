class Pulp3MigrationProgress < ActiveRecord::Migration[6.0]
  def change
    create_table :katello_content_migration_progresses do |t|
      t.string :progress_message
      t.boolean :canceled, null: false, default: false
      t.string :task_id, null: false, index: {name: 'katello_content_migration_progress_task_id', unique: true }
    end
  end
end
