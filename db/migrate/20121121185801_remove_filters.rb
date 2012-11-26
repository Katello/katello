class RemoveFilters < ActiveRecord::Migration
  def self.up
    remove_index :filters_products, :column=>:filter_id
    remove_index :filters_products, :column=>:product_id

    drop_table "filters_products"

    remove_index :filters_repositories, :column=>:filter_id
    remove_index :filters_repositories, :column=>:repository_id

    drop_table "filters_repositories"

    drop_table "filter_packages"

    remove_index :filters, :column=>:pulp_id
    remove_index :filters, :column=>:organization_id
    remove_index(:filters, :column => [:name, :organization_id])

    drop_table :filters
  end

  def self.down
    create_table :filters, :force => true do |t|
      t.string  :pulp_id
      t.string   "name", :null => false
      t.string   "description"
      t.references :organization
      t.timestamps
    end
    add_index "filters", ["name", "organization_id"], :name => "index_filters_on_name_and_organization_id", :unique => true
    add_index "filters", ["organization_id"], :name => "index_filters_on_organization_id"
    add_index "filters", ["pulp_id"], :name => "index_filters_on_pulp_id"


    create_table "filters_products", :id => false, :force => true do |t|
      t.integer "filter_id"
      t.integer "product_id"
    end

    add_index "filters_products", ["filter_id"], :name => "index_filters_products_on_filter_id"
    add_index "filters_products", ["product_id"], :name => "index_filters_products_on_product_id"

    create_table "filters_repositories", :id => false, :force => true do |t|
      t.integer "filter_id"
      t.integer "repository_id"
    end

    add_index "filters_repositories", ["filter_id"], :name => "index_filters_repositories_on_filter_id"
    add_index "filters_repositories", ["repository_id"], :name => "index_filters_repositories_on_repository_id"

    create_table "filter_packages", :force => true do |t|
      t.integer "filter_id"
      t.string  "name",      :null => false
    end

  end
end
