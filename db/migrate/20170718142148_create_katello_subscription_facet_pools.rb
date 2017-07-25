class CreateKatelloSubscriptionFacetPools < ActiveRecord::Migration
  def change
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
