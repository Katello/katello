class MoveSubscriptionProducts < ActiveRecord::Migration[5.1]
  class FakeSubscription < ApplicationRecord
    self.table_name = 'katello_subscriptions'
    has_many :pools, :class_name => "FakePool", :inverse_of => :subscription, :foreign_key => 'subscription_id'
    has_many :subscription_products, :class_name => "FakeSubscriptionProduct", :inverse_of => :subscription, :foreign_key => 'subscription_id'
  end

  class FakeSubscriptionProduct < ApplicationRecord
    self.table_name = 'katello_subscription_products'
    belongs_to :subscription, :inverse_of => :subscription_products, :class_name => 'FakeSubscription'
  end

  class FakePool < ApplicationRecord
    self.table_name = 'katello_pools'
    belongs_to :subscription, :inverse_of => :pools, :class_name => "FakeSubscription"
    has_many :pool_products, :class_name => "FakePoolProducts", :inverse_of => :pool, :foreign_key => 'pool_id'
  end

  class FakePoolProducts < ApplicationRecord
    self.table_name = 'katello_pool_products'
    belongs_to :pool, :inverse_of => :pool_products, :class_name => 'FakePool'
  end

  def up
    create_table "katello_pool_products" do |t|
      t.references :pool
      t.references :product
      t.timestamps
    end
    add_index "katello_pool_products", [:pool_id, :product_id], :unique => true,
              :name => "index_katello_pool_products_on_subs_id_prod_id"

    add_foreign_key "katello_pool_products", "katello_pools",
                    :name => "katello_pool_products_pool_id_fk", :column => "pool_id"
    add_foreign_key "katello_pool_products", "katello_products",
                    :name => "katello_pool_products_product_id_fk", :column => "product_id"

    FakeSubscription.reset_column_information
    FakeSubscription.find_each do |sub|
      sub.subscription_products.each do |sub_product|
        sub.pool_ids.each do |pool_id|
          FakePoolProducts.create!(:pool_id => pool_id, :product_id => sub_product.product_id)
        end
      end
    end

    drop_table "katello_subscription_products"
  end

  def down
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

    FakeSubscription.reset_column_information
    FakeSubscription.find_each do |sub|
      pool = sub.pools.first
      if pool
        product_ids = pool.pool_products.pluck(:product_id)
        product_ids.each do |product_id|
          FakeSubscriptionProduct.create!(:product_id => product_id, :subscription_id => sub.id)
        end
      end
    end

    drop_table "katello_pool_products"
  end
end
