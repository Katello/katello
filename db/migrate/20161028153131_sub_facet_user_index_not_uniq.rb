class SubFacetUserIndexNotUniq < ActiveRecord::Migration
  def up
    remove_index :katello_subscription_facets, [:user_id]
    add_index :katello_subscription_facets, [:user_id], :unique => false
  end

  def down
    remove_index :katello_subscription_facets, [:user_id]
    add_index :katello_subscription_facets, [:user_id], :unique => true
  end
end
