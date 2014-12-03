class AddSyncPlanEnabledToSyncPlan < ActiveRecord::Migration
  def up
    add_column :katello_sync_plans, :enabled, :boolean, :default => true, :null => false
  end

  def down
    remove_column :katello_sync_plans, :enabled
  end
end
