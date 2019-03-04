class RemoveEnabledFromSyncPlans < ActiveRecord::Migration[5.2]
  def change
    remove_column :katello_sync_plans, :enabled
  end
end
