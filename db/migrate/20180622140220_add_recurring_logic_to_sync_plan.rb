class AddRecurringLogicToSyncPlan < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_sync_plans, :foreman_tasks_recurring_logic_id, :integer
    add_foreign_key :katello_sync_plans, :foreman_tasks_recurring_logics, :name => "katello_sync_plan_foreman_tasks_recurring_logic_fk", :column => "foreman_tasks_recurring_logic_id"
    Katello::SyncPlan.find_each do |sync_plan|
      User.as_anonymous_admin do
        sync_plan.associate_recurring_logic
        sync_plan.save!
      end
    end
  end
end
