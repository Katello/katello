class AddRegisteredThroughToKatelloSubscriptionFacets < ActiveRecord::Migration
  def change
    add_column :katello_subscription_facets, :registered_through, :string
  end
end
