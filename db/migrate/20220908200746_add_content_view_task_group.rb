class AddContentViewTaskGroup < ActiveRecord::Migration[6.1]
  def change
    add_column :katello_content_views, :task_group_id, :integer, :index => true
    add_foreign_key :katello_content_views, :foreman_tasks_task_groups, :column => :task_group_id
  end
end
