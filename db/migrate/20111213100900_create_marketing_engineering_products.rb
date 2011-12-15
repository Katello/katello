class CreateMarketingEngineeringProducts < ActiveRecord::Migration
  def self.up
    create_table :marketing_engineering_products do |t|
      t.integer :marketing_product_id
      t.integer :engineering_product_id
    end
    add_index :marketing_engineering_products, :marketing_product_id
    add_index :marketing_engineering_products, :engineering_product_id
  end

  def self.down
    drop_table :marketing_engineering_products
  end
end
