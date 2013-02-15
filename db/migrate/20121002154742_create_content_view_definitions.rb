class CreateContentViewDefinitions < ActiveRecord::Migration
  def self.up
    create_table :content_view_definitions do |t|
      t.string :name
      t.string :label, :null => false
      t.text :description
      t.references :organization

      t.timestamps
    end

    add_index :content_view_definitions, [:organization_id, :label], :unique => true
  end

  def self.down
    drop_table :content_view_definitions
  end
end
