class AddIndicesToContentViewNames < ActiveRecord::Migration
  def self.up
    add_index :content_views, [:name, :organization_id]
    add_index :content_view_definitions, [:name, :organization_id]
  end

  def self.down
    remove_index :content_views, [:name, :organization_id]
    remove_index :content_view_definitions, [:name, :organization_id]
  end
end
