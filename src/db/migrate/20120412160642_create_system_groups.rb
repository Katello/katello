class CreateSystemGroups < ActiveRecord::Migration
  def self.up
    create_table :system_groups do |t|
      t.string :name, :null=>false
      t.string :pulp_id, :null=>false
      t.string :description, :null=>true
      t.integer :max_systems, :null=>false, :default=>-1
      t.references :organization, :null=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :system_groups
  end
end
