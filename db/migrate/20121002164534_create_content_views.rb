class CreateContentViews < ActiveRecord::Migration
  def self.up
    create_table :content_views do |t|
      t.string :name
      t.string :label, :null => false
      t.text :description
      t.references :content_view_definition
      t.references :organization
      t.boolean :default, :default => false, :null => false
      t.timestamps
    end

    add_index :content_views, :content_view_definition_id
    add_index :content_views, :organization_id
    add_index :content_views, [:organization_id, :label], :unique => true
  end

  def self.down
    drop_table :content_views
  end
end
