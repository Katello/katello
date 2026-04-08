class DropKatelloTaskStatuses < ActiveRecord::Migration[7.0]
  def change
    remove_column :katello_providers, :task_status_id
    drop_table :katello_task_statuses
  end
end
