class CreatePermissionTag < ActiveRecord::Migration
  def self.up
    create_table :permission_tags do |t|
      t.integer :permission_id
      t.integer :tag_id
      t.timestamps
    end
  end

  def self.down
    drop_table :permission_tags
  end
end
