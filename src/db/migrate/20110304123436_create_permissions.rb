class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.belongs_to :role, :resource_type, :organization
      t.boolean :all_tags, :default => false
      t.boolean :all_verbs, :default => false
      t.timestamps
    end
    add_index :permissions, :role_id
    add_index :permissions, :resource_type_id, :null =>true
    add_index :permissions, :organization_id, :null =>true
  end

  def self.down
    remove_index :permissions, :role_id
    remove_index :permissions, :resource_type_id
    remove_index :permissions, :organization_id, :null =>true
    drop_table :permissions
  end
end
