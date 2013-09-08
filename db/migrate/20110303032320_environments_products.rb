class EnvironmentsProducts < ActiveRecord::Migration
  def self.up
    create_table :environment_products do |t|
      t.references :environment, :null => false
      t.references :product, :null => false
    end
    add_index(:environment_products, [:environment_id, :product_id], :unique => true)
  end

  def self.down
    remove_index :environment_products, [:environment_id, :product_id]
    drop_table :environment_products
  end
end
