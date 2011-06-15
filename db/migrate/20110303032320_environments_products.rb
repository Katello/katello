class EnvironmentsProducts < ActiveRecord::Migration
  def self.up
    create_table :kp_environments_products, :id => false do |t|
       t.integer :kp_environment_id
       t.integer :product_id
    end
  end

  def self.down
    drop_table :kp_environments_products
  end
end
