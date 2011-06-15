class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.belongs_to :role, :resource_type
      t.boolean :all_tags, :default => false
      t.boolean :all_verbs, :default => false
      t.timestamps
    end
    add_index :permissions, :role_id
    add_index :permissions, :resource_type_id
  end

  def self.down
    remove_index :permissions, :role_id
    remove_index :permissions, :resource_type_id
    drop_table :permissions
  end
end
