class AddRegisteredAtToSubscriptionFacet < ActiveRecord::Migration[4.2]
  def up
    add_column(:katello_subscription_facets, :registered_at, :datetime, :null => false, :default => Time.now)
  end

  def down
    remove_column(:katello_subscription_facets, :registered_at)
  end
end
