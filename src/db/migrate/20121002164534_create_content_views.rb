class CreateContentViews < ActiveRecord::Migration
  def self.up
    create_table :content_views do |t|
      t.string :name
      t.text :description
      t.references :content_view_definition
      t.references :organization

      t.timestamps
    end
  end

  def self.down
    drop_table :content_views
  end
end
