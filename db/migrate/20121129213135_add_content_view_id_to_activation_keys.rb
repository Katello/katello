class AddContentViewIdToActivationKeys < ActiveRecord::Migration
  def self.up
    add_column :activation_keys, :content_view_id, :integer
    add_index :activation_keys, :content_view_id
  end

  def self.down
    remove_index :activation_keys, :content_view_id
    remove_column :activation_keys, :content_view_id
  end
end
