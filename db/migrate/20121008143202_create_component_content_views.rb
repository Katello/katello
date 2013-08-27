class CreateComponentContentViews < ActiveRecord::Migration
  def self.up
    create_table :component_content_views do |t|
      t.references :content_view_definition
      t.references :content_view

      t.timestamps
    end
    add_index :component_content_views, [:content_view_definition_id, :content_view_id],
              :name => "component_content_views_index"
  end

  def self.down
    drop_table :component_content_views
  end
end
