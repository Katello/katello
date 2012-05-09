class FiltersProducts < ActiveRecord::Migration
  def self.up
    create_table :filters_products, :id => false do |t|
       t.integer :filter_id
       t.integer :product_id
    end
  end

  def self.down
    drop_table :filters_products
  end
end
