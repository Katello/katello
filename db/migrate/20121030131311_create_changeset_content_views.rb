class CreateChangesetContentViews < ActiveRecord::Migration
  def self.up
    create_table :changeset_content_views do |t|
      t.references :changeset
      t.references :content_view

      t.timestamps
    end
  end

  def self.down
    drop_table :changeset_content_views
  end
end
