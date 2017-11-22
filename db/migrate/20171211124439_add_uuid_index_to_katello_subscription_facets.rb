class AddUuidIndexToKatelloSubscriptionFacets < ActiveRecord::Migration[4.2]
  def change
    add_index :katello_subscription_facets, :uuid
  end
end
