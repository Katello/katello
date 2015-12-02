class AddSubscriptionFacet < ActiveRecord::Migration
  def change
    create_table "katello_subscription_facets" do |t|
      t.references 'host', :null => false
      t.string 'uuid'
      t.datetime 'last_checkin'
      t.string 'service_level'
      t.string 'release_version'
      t.boolean 'autoheal', :default => false
    end

    add_index :katello_subscription_facets, [:host_id], :unique => true, :name => :katello_subscription_facets_host_id

    add_foreign_key "katello_subscription_facets", "hosts",
                    :name => "katello_subscription_facets_host_id", :column => "host_id"

    create_table "katello_subscription_facet_activation_keys" do |t|
      t.references :subscription_facet, :null => false, :index => { :name => "katello_subscription_facet_activation_keys_sf" }
      t.references :activation_key, :null => false, :index => { :name => "katello_subscription_facet_activation_keys_ak" }
    end

    add_index :katello_subscription_facet_activation_keys, [:subscription_facet_id, :activation_key_id], :unique => true,
                                                                 :name => :katello_subscription_facet_activation_keys_sa_ak_id

    add_foreign_key "katello_subscription_facet_activation_keys", "katello_subscription_facets",
                    :name => "katello_subscription_facet_activation_keys_sa_id", :column => "subscription_facet_id"
    add_foreign_key "katello_subscription_facet_activation_keys", "katello_activation_keys",
                    :name => "katello_subscription_facet_activation_keys_ak_id", :column => "activation_key_id"
  end
end
