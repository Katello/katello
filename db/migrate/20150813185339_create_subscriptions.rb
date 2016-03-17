class CreateSubscriptions < ActiveRecord::Migration
  # rubocop:disable MethodLength
  def change
    create_table "katello_subscriptions" do |t|
      t.string  :name, :limit => 255
      t.string  :product_id, :limit => 255
      t.string  :cp_id, :limit => 255
      t.string  :support_level
      t.integer :organization_id
      t.integer :sockets
      t.integer :cores
      t.integer :stacking_id
      t.integer :instance_multiplier

      t.timestamps
    end

    add_column :katello_pools, :subscription_id, :integer
    add_column :katello_pools, :account_number, :integer
    add_column :katello_pools, :contract_number, :integer
    add_column :katello_pools, :virtual, :boolean
    add_column :katello_pools, :quantity, :integer
    add_column :katello_pools, :start_date, :string, :limit => 255
    add_column :katello_pools, :pool_type, :string, :limit => 255
    add_column :katello_pools, :end_date, :string, :limit => 255
    add_column :katello_pools, :ram, :integer
    add_column :katello_pools, :multi_entitlement, :boolean
    add_column :katello_pools, :consumed, :integer

    add_foreign_key :katello_subscriptions, :taxonomies,
                    :name => 'katello_subscriptions_organization_fk', :column => 'organization_id'

    add_foreign_key :katello_pools, :katello_subscriptions,
                    :name => 'katello_pools_subscriptions_fk', :column => 'subscription_id'

    add_index  :katello_subscriptions, :cp_id, :unique => true
    add_index  :katello_pools, :cp_id, :unique => true

    create_table "katello_subscription_products" do |t|
      t.references :subscription
      t.references :product
      t.timestamps
    end
    add_index "katello_subscription_products", [:subscription_id, :product_id], :unique => true,
              :name => "index_katello_subscriptions_products_on_subs_id_prod_id"

    add_foreign_key "katello_subscription_products", "katello_subscriptions",
                    :name => "katello_subscription_products_subscription_id_fk", :column => "subscription_id"
    add_foreign_key "katello_subscription_products", "katello_products",
                    :name => "katello_subscription_products_product_id_fk", :column => "product_id"

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
  end

  def down
    drop_table "katello_subscriptions"
    drop_table "katello_subscriptions_products"
    drop_table "katello_pool_activation_keys"
    remove_column :katello_pools, :subscription_id
    remove_column :katello_pools, :account_number
    remove_column :katello_pools, :contract_number
    remove_column :katello_pools, :virtual
    remove_column :katello_pools, :quantity
    remove_column :katello_pools, :start_date
    remove_column :katello_pools, :end_date
    remove_column :katello_pools, :ram
    remove_column :katello_pools, :multi_entitlement
    remove_column :katello_pools, :consumed
    remove_column :katello_pools, :pool_type
  end
end
