class AddDmiUuidToKatelloSubscriptionFacets < ActiveRecord::Migration[5.2]
  def change
    add_column :katello_subscription_facets, :dmi_uuid, :string
    add_index :katello_subscription_facets, :dmi_uuid
  end
end
