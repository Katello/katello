class AddRepositoriesAndProductsToAcs < ActiveRecord::Migration[6.1]
  def change
    add_reference :katello_smart_proxy_alternate_content_sources, :repository, null: true, index: false
    remove_index :katello_smart_proxy_alternate_content_sources, [:alternate_content_source_id, :smart_proxy_id]
    add_index :katello_smart_proxy_alternate_content_sources, [:alternate_content_source_id, :smart_proxy_id, :repository_id],
              name: 'index_katello_smart_proxy_acs_on_acs_id_smart_proxy_id_repo_id'

    create_table 'katello_alternate_content_source_products' do |t|
      t.references :alternate_content_source, null: false, index: false
      t.references :product, null: false, index: false
    end

    add_foreign_key 'katello_alternate_content_source_products', 'katello_alternate_content_sources',
      name: 'katello_alternate_content_source_products_id_fk', column: 'alternate_content_source_id'
    add_foreign_key 'katello_alternate_content_source_products', 'katello_products',
      name: 'katello_alternate_content_source_products_repo_id_fk', column: 'product_id'

    add_index :katello_alternate_content_source_products, :alternate_content_source_id,
      name: 'index_katello_acs_products_on_acs_id'
    add_index :katello_alternate_content_source_products, :product_id,
      name: 'index_katello_acs_products_on_product_id'
  end
end
