class SubscriptionCpIdChange < ActiveRecord::Migration[5.1]
  def up
    remove_column :katello_subscriptions, :cp_id
    rename_column :katello_subscriptions, :product_id, :cp_id
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
