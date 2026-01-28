class DropKatelloSubscriptionFacetPoolsAndPoolActivationKeys < ActiveRecord::Migration[7.0]
  def change
    drop_table :katello_pool_activation_keys, if_exists: true
    drop_table :katello_subscription_facet_pools, if_exists: true

    NotificationBlueprint.where(name: ['sca_disable_error', 'sca_disable_success', 'sca_enable_error', 'sca_enable_success']).destroy_all
  end
end
