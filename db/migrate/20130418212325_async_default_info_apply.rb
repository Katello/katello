class AsyncDefaultInfoApply < ActiveRecord::Migration

  def up
    rename_column :organizations, :task_id, :deletion_task_id
    add_column :organizations, :apply_info_task_id, :integer
  end

  def down
    remove_column :organizations, :apply_info_task_id
    rename_column :organizations, :deletion_task_id, :task_id
  end
end
