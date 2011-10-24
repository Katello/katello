class EnvironmentsProducts < ActiveRecord::Migration
  def self.up
    create_table :environment_products do |t|
       t.references :environment, :null =>false
       t.references :product, :null =>false
    end
  end

  def self.down
    drop_table :environment_products
  end
end
