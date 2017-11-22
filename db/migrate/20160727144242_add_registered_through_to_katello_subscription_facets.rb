class AddRegisteredThroughToKatelloSubscriptionFacets < ActiveRecord::Migration[4.2]
  def change
    add_column :katello_subscription_facets, :registered_through, :string
  end
end
