class CreateContentViewComponents < ActiveRecord::Migration
  def self.up
    create_table :content_view_components do |t|
      t.references :composite
      t.references :component

      t.timestamps
    end
  end

  def self.down
    drop_table :content_view_components
  end
end
