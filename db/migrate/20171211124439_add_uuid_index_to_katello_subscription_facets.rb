class AddUuidIndexToKatelloSubscriptionFacets < ActiveRecord::Migration
  def change
    add_index :katello_subscription_facets, :uuid
  end
end
