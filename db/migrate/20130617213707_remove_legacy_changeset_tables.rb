class RemoveLegacyChangesetTables < ActiveRecord::Migration
  def up
    drop_table :changeset_dependencies
    drop_table :changeset_distributions
    drop_table :changeset_errata
    drop_table :changeset_packages
    drop_table :changesets_products
    drop_table :changesets_repositories
  end

  def down
    create_table "changeset_dependencies", :force => true do |t|
      t.integer "changeset_id"
      t.string  "package_id"
      t.string  "display_name"
      t.integer "product_id",    :null => false
      t.string  "dependency_of"
    end
    add_index "changeset_dependencies", ["changeset_id"], :name => "index_changeset_dependencies_on_changeset_id"
    add_index "changeset_dependencies", ["package_id"], :name => "index_changeset_dependencies_on_package_id"
    add_index "changeset_dependencies", ["product_id"], :name => "index_changeset_dependencies_on_product_id"

    create_table "changeset_distributions", :force => true do |t|
      t.integer "changeset_id"
      t.string  "distribution_id"
      t.string  "display_name"
      t.integer "product_id",      :null => false
    end
    add_index "changeset_distributions", ["changeset_id"], :name => "index_changeset_distributions_on_changeset_id"
    add_index "changeset_distributions", %w(distribution_id changeset_id product_id), :name => "index_cs_distro_distro_id_cs_id_p_id", :unique => true
    add_index "changeset_distributions", ["distribution_id"], :name => "index_changeset_distributions_on_distribution_id"
    add_index "changeset_distributions", ["product_id"], :name => "index_changeset_distributions_on_product_id"

    create_table "changeset_errata", :force => true do |t|
      t.integer "changeset_id"
      t.string  "errata_id"
      t.string  "display_name"
      t.integer "product_id",   :null => false
    end
    add_index "changeset_errata", ["changeset_id"], :name => "index_changeset_errata_on_changeset_id"
    add_index "changeset_errata", %w(errata_id changeset_id), :name => "index_changeset_errata_on_errata_id_and_changeset_id", :unique => true
    add_index "changeset_errata", ["errata_id"], :name => "index_changeset_errata_on_errata_id"
    add_index "changeset_errata", ["product_id"], :name => "index_changeset_errata_on_product_id"

    create_table "changeset_packages", :force => true do |t|
      t.integer "changeset_id"
      t.string  "package_id"
      t.string  "display_name"
      t.integer "product_id",   :null => false
      t.string  "nvrea"
    end
    add_index "changeset_packages", ["changeset_id"], :name => "index_changeset_packages_on_changeset_id"
    add_index "changeset_packages", %w(nvrea changeset_id), :name => "index_changeset_packages_on_nvrea_and_changeset_id", :unique => true
    add_index "changeset_packages", ["package_id"], :name => "index_changeset_packages_on_package_id"
    add_index "changeset_packages", ["product_id"], :name => "index_changeset_packages_on_product_id"

    create_table "changesets_products", :id => false, :force => true do |t|
      t.integer "changeset_id"
      t.integer "product_id"
    end
    add_index "changesets_products", ["changeset_id"], :name => "index_changesets_products_on_changeset_id"
    add_index "changesets_products", ["product_id"], :name => "index_changesets_products_on_product_id"

    create_table "changesets_repositories", :id => false, :force => true do |t|
      t.integer "changeset_id",  :null => false
      t.integer "repository_id", :null => false
    end
    add_index "changesets_repositories", ["changeset_id"], :name => "index_changesets_repositories_on_changeset_id"
    add_index "changesets_repositories", ["repository_id"], :name => "index_changesets_repositories_on_repository_id"
  end
end
