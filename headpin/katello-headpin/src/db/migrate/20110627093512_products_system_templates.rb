class ProductsSystemTemplates < ActiveRecord::Migration
  def self.up
    create_table :products_system_templates, :id => false do |t|
       t.integer :system_template_id
       t.integer :product_id
    end
  end

  def self.down
    drop_table :products_system_templates
  end
end
