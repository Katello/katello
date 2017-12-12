class DropMarketingEngineeringProducts < ActiveRecord::Migration[4.2]
  class Katello::MarketingProduct < ApplicationRecord
    self.table_name = "katello_products"
  end

  def up
    drop_table :katello_marketing_engineering_products
    Katello::Product.where(:type => "Katello::MarketingProduct").delete_all

    remove_column :katello_products, :type
  end

  def down
    create_table "katello_marketing_engineering_products", :force => true do |t|
      t.integer "marketing_product_id"
      t.integer "engineering_product_id"
    end

    add_column :katello_products, :type, :string, :limit => 255
  end
end
