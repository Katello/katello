class CreateRepository < ActiveRecord::Migration
  def self.up
    create_table :repositories do |t|
      t.string :name
      t.string :pulp_id
      t.boolean :blacklisted, :default => false
      t.references :product, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :repositories
  end
end
