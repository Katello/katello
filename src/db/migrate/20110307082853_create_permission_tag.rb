class CreatePermissionTag < ActiveRecord::Migration
  def self.up
    create_table :permissions_tags, :id => false do |t|
      t.belongs_to :permission, :tag
    end
    add_index :permissions_tags, :permission_id
    add_index :permissions_tags, :tag_id
  end

  def self.down
    remove_index :permissions_tags, :tag_id
    remove_index :permissions_tags, :permission_id
    drop_table :permissions_tags
  end
end
