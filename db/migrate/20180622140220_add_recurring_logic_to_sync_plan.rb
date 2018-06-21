class AddRecurringLogicToSyncPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_sync_plans, :recurring_logic_id, :integer
    add_foreign_key :katello_sync_plans, :foreman_tasks_recurring_logics, :name => "katello_sync_plan_recurring_logic_fk", :column => "recurring_logic_id"
  end
end
