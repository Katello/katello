class RemoveEnvironmentProducts < ActiveRecord::Migration

  class EnvironmentProduct < ActiveRecord::Base
  end

  class Repoistory < ActiveRecord::Base
  end

  def up
    add_column :repositories, :product_id, :int
    add_column :repositories, :environment_id, :int
    add_index :repositories, :product_id
    add_index :repositories, :environment_id

    EnvironmentProduct.all.each do |env_prod|
      [:product_id, :environment_id].each do |attr|
        if (val = env_prod.send(attr))
          Repository.update_all("#{attr.to_s} = #{val}",
                                "environment_product_id = #{env_prod.id}"
                               )
        end
      end
    end

    remove_column :repositories, :environment_product_id
    drop_table :environment_products
  end

  def down
    # NOTE: this does not repopulate the environment_products table
    remove_column :repositories, :product_id
    remove_column :repositories, :environment_id

    create_table "environment_products", :force => true do |t|
      t.integer "environment_id", :null => false
      t.integer "product_id",     :null => false
    end

    add_index "environment_products", ["environment_id", "product_id"], :name => "index_environment_products_on_environment_id_and_product_id", :unique => true

    add_column :repositories, :environment_product_id, :int
    add_index "repositories", ["environment_product_id"], :name => "index_repositories_on_environment_product_id"
    add_index "repositories", ["label", "content_view_version_id", "environment_product_id"], :name => "repositories_l_cvvi_epi", :unique => true
  end
end
