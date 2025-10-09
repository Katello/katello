class RemoveAutohealFromSubscriptionFacets < ActiveRecord::Migration[6.1]
  def change
    remove_column :katello_subscription_facets, :autoheal, :boolean
  end
end
