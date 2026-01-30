class DropKatelloSubscriptionFacetPoolsAndPoolActivationKeys < ActiveRecord::Migration[7.0]
  def up
    drop_table :katello_pool_activation_keys
    drop_table :katello_subscription_facet_pools

    NotificationBlueprint.where(name: ['sca_disable_error', 'sca_disable_success', 'sca_enable_error', 'sca_enable_success']).destroy_all
  end

  def down
    create_table "katello_pool_activation_keys" do |t|
      t.references :pool
      t.references :activation_key
      t.timestamps
    end
    add_index "katello_pool_activation_keys", [:pool_id, :activation_key_id], :unique => true,
              :name => "index_katello_pools_activation_keys_on_ack_id_pool_id"

    add_foreign_key "katello_pool_activation_keys", "katello_pools",
                    :name => "katello_pool_activation_keys_pool_id_fk", :column => "pool_id"
    add_foreign_key "katello_pool_activation_keys", "katello_activation_keys",
                   :name => "katello_pool_activation_keys_ack_key_id_fk", :column => "activation_key_id"

    create_table :katello_subscription_facet_pools do |t|
      t.column :subscription_facet_id, :integer, required: true
      t.column :pool_id, :integer, required: true
    end
    add_index "katello_subscription_facet_pools", [:pool_id, :subscription_facet_id], :unique => true,
              :name => "index_katello_sub_facet_pools_on_sfid_poolid"

    add_foreign_key "katello_subscription_facet_pools", "katello_pools",
                    :name => "katello_sub_facet_pools_pool_id_fk", :column => "pool_id"
    add_foreign_key "katello_subscription_facet_pools", "katello_subscription_facets",
                   :name => "katello_sub_facet_pools_sf_id_fk", :column => "subscription_facet_id"
  end
end
