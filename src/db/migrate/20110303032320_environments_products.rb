class EnvironmentsProducts < ActiveRecord::Migration
  def self.up
    create_table :kt_environments_products, :id => false do |t|
       t.integer :kt_environment_id
       t.integer :product_id
    end
  end

  def self.down
    drop_table :kt_environments_products
  end
end
