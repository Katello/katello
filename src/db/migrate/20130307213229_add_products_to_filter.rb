class AddProductsToFilter < ActiveRecord::Migration
  def self.up
    create_table :filters_products, :id => false do |t|
      t.references :filter
      t.references :product
    end

    add_index :filters_products, :filter_id
    add_index :filters_products, :product_id
    add_index(:filters_products, [:filter_id, :product_id], :unique => true)
  end

  def self.down
    remove_index :filters_products, :column => :filter_id
    remove_index :filters_products, :column => :product_id
    remove_index(:filters_products, :column =>[:filter_id, :product_id])

    drop_table :filters_products
  end
end
