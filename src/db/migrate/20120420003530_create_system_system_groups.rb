class CreateSystemSystemGroups < ActiveRecord::Migration
  def self.up
    create_table :system_system_groups do |t|
      t.references :system
      t.references :system_group
      t.timestamps
    end
  end

  def self.down
    drop_table :system_system_groups
  end
end
