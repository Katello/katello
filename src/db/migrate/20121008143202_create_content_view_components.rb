class CreateContentViewComponents < ActiveRecord::Migration
  def self.up
    create_table :content_view_components do |t|
      t.references :composite
      t.references :component

      t.timestamps
    end
    add_index :content_view_components, [:component_id, :composite_id]
  end

  def self.down
    drop_table :content_view_components
  end
end
