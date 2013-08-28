class RemoveEnvironmentProducts < ActiveRecord::Migration

  def up
    remove_column :repositories, :environment_product_id
    drop_table :environment_products
  end

  def down
    create_table "environment_products", :force => true do |t|
      t.integer "environment_id", :null => false
      t.integer "product_id",     :null => false
    end

    add_column :repositories, :environment_product_id, :int

    add_index "environment_products", %w(environment_id product_id), :name => "index_environment_products_on_environment_id_and_product_id", :unique => true

    add_index "repositories", ["environment_product_id"], :name => "index_repositories_on_environment_product_id"
    add_index "repositories", %w(label content_view_version_id environment_product_id), :name => "repositories_l_cvvi_epi", :unique => true
  end
end
