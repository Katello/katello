class AddCompositeTypeToContentViewDefinitions < ActiveRecord::Migration
  def self.up
    add_column :content_view_definitions, :composite, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :content_view_definitions, :composite
  end
end
