class AddCronLogicToSyncPlans < ActiveRecord::Migration[5.1]
  def change
    add_column :katello_sync_plans, :cron_expression, :string
  end
end
