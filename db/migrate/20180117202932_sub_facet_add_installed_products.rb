class SubFacetAddInstalledProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :katello_installed_products do |t|
      t.string :name
      t.string :cp_product_id
      t.string :arch
      t.string :version
    end

    create_table :katello_subscription_facet_installed_products do |t|
      t.references :installed_product, :index => {:name => :katello_sub_facet_installed_products_ipid}
      t.references :subscription_facet, :index => {:name => :katello_sub_facet_installed_products_sfid}
    end

    add_foreign_key "katello_subscription_facet_installed_products", "katello_subscription_facets",
                        :name => "katello_sub_facet_installed_product_facet_id", :column => "subscription_facet_id"
    add_foreign_key "katello_subscription_facet_installed_products", "katello_installed_products",
                        :name => "katello_sub_facet_installed_product_product_id", :column => "installed_product_id"
  end
end
