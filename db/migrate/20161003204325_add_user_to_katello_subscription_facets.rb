class AddUserToKatelloSubscriptionFacets < ActiveRecord::Migration
  def change
    add_column :katello_subscription_facets, :user_id, :integer
    add_index :katello_subscription_facets, [:user_id], :unique => true
    add_foreign_key "katello_subscription_facets", "users", :column => "user_id"
  end
end
