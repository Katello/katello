class ChangesetsProducts < ActiveRecord::Migration
  def self.up
    create_table :changesets_products, :id => false do |t|
       t.integer :changeset_id
       t.integer :product_id
    end
  end

  def self.down
    drop_table :changesets_products
  end
end
