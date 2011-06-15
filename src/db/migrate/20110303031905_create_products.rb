class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.string :name
      t.string :description
      t.string :cp_id
      t.integer :multiplier
      t.references :provider, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
