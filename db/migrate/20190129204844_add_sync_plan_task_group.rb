class AddSyncPlanTaskGroup < ActiveRecord::Migration[5.2]
  class FakeSyncPlan < Katello::Model
    self.table_name = 'katello_sync_plans'
  end

  def up
    add_column :katello_sync_plans, :task_group_id, :integer, :index => true
    add_foreign_key :katello_sync_plans, :foreman_tasks_task_groups, :column => :task_group_id
    FakeSyncPlan.all.each do |plan|
      plan.task_group_id ||= Katello::SyncPlanTaskGroup.create!.id
      plan.save!
    end
  end

  def down
    remove_column :katello_sync_plans, :task_group_id
    ForemanTasks::TaskGroup.where(:type => "Katello::SyncPlanTaskGroup").delete_all
  end
end
