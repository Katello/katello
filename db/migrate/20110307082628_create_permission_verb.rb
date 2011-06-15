class CreatePermissionVerb < ActiveRecord::Migration
  def self.up
    create_table :permissions_verbs, :id => false do |t|
      t.belongs_to :permission, :verb
    end
    add_index :permissions_verbs, :permission_id
    add_index :permissions_verbs, :verb_id
  end

  def self.down
    remove_index :permissions_verbs, :permission_id
    remove_index :permissions_verbs, :verb_id
    drop_table :permissions_verbs
  end
end
