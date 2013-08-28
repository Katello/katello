class CreateContentViewDefinitionProducts < ActiveRecord::Migration
  def self.up
    create_table :content_view_definition_products do |t|
      t.references :content_view_definition
      t.references :product

      t.timestamps
    end
    add_index :content_view_definition_products, [:content_view_definition_id, :product_id],
              :name => "content_view_def_product_index"
  end

  def self.down
    drop_table :content_view_definition_products
  end
end
