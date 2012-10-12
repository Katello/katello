class CreateContentViewDefinitions < ActiveRecord::Migration
  def self.up
    create_table :content_view_definitions do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :content_view_definitions
  end
end
