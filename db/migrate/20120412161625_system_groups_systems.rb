class SystemGroupsSystems < ActiveRecord::Migration
  def self.up
    create_table :system_group_systems do |t|
      t.references :system_group, :null=>false
      t.references :system, :null=>false
    end
    add_index(:system_group_systems, [:system_group_id, :system_id], :unique=>true)
  end

  def self.down
    remove_index :system_group_systems, [:system_group_id, :system_id]
    drop_table :system_group_systems
  end
end
