class RefactorContentViews < ActiveRecord::Migration
  def up
    remove_foreign_key "katello_component_content_views", :name => "component_content_views_content_view_definition_id_fk"
    remove_foreign_key "katello_content_view_definition_bases", :name => "content_view_definition_bases_source_id_fk"
    remove_foreign_key "katello_content_view_definition_products", :name => "content_view_definition_products_content_view_definition_id_fk"
    remove_foreign_key "katello_content_view_definition_products", :name => "content_view_definition_products_product_id_fk"

    remove_foreign_key "katello_content_view_definition_repositories", :name => "CV_definition_repositories_CV_definition_id_fk"
    remove_foreign_key "katello_content_view_versions", :name => "content_view_versions_content_view_definition_archive_id_fk"
    remove_foreign_key "katello_content_view_versions", :name => "content_view_versions_definition_archive_id_fk"
    remove_foreign_key "katello_content_views", :name => "content_views_content_view_definition_id_fk"
    remove_foreign_key "katello_filters", :name => "filters_content_view_definition_id_fk"
    remove_foreign_key "katello_filters_products", :name => "filters_product_filter_id_fk"
    remove_foreign_key "katello_filters_products", :name => "filters_product_product_id_fk"
    remove_foreign_key "katello_filter_rules", :name => "filters_rules_filter_id_fk"

    drop_table :katello_content_view_definition_bases
    drop_table :katello_content_view_definition_products
    drop_table :katello_filters_products
    drop_table :katello_filter_rules
    drop_table :katello_content_view_version_environments

    add_column :katello_content_views, :composite, :boolean
    add_column :katello_content_view_environments, :content_view_version_id, :integer
    remove_column :katello_content_views, :content_view_definition_id

    rename_column :katello_component_content_views, :content_view_definition_id, :content_view_version_id
    rename_table :katello_component_content_views, :katello_content_view_components

    rename_table :katello_content_view_definition_repositories, :katello_content_view_repositories
    rename_column :katello_content_view_repositories, :content_view_definition_id, :content_view_id

    # katello filters
    rename_column :katello_filters, :content_view_definition_id, :content_view_id
    add_column :katello_filters, :type, :string
    add_column :katello_filters, :inclusion, :boolean, :default => false, :null => false
    add_column :katello_filters, :parameters, :text
  end

  def down
    create_table "katello_content_view_definition_bases", :force => true do |t|
      t.string   "name"
      t.string   "label",                              :null => false
      t.text     "description"
      t.integer  "organization_id"
      t.datetime "created_at",                         :null => false
      t.datetime "updated_at",                         :null => false
      t.boolean  "composite",       :default => false, :null => false
      t.string   "type"
      t.integer  "source_id"
    end

    create_table "katello_content_view_definition_products", :force => true do |t|
      t.integer  "content_view_definition_id"
      t.integer  "product_id"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
    end

    create_table "katello_filters_products", :id => false, :force => true do |t|
      t.integer "filter_id"
      t.integer "product_id"
    end

    create_table "katello_filter_rules", :force => true do |t|
      t.string   "type"
      t.text     "parameters"
      t.integer  "filter_id",                    :null => false
      t.boolean  "inclusion",  :default => true
      t.datetime "created_at",                   :null => false
      t.datetime "updated_at",                   :null => false
    end

    create_table "katello_content_view_version_environments", :force => true do |t|
      t.integer  "content_view_version_id"
      t.integer  "environment_id"
      t.datetime "created_at",              :null => false
      t.datetime "updated_at",              :null => false
    end

    remove_column :katello_content_views, :composite
    remove_column :katello_content_view_environments, :content_view_version_id
    add_column :katello_content_views, :content_view_definition_id, :integer

    rename_table :katello_content_view_components, :katello_component_content_views
    rename_column :katello_component_content_views, :content_view_version_id, :content_view_definition_id

    rename_column :katello_content_view_repositories, :content_view_id, :content_view_definition_id
    rename_table :katello_content_view_repositories, :katello_content_view_definition_repositories

    # katello filters
    rename_column :katello_filters, :content_view_id, :content_view_definition_id
    remove_column :katello_filters, :type
    remove_column :katello_filters, :parameters

    add_foreign_key "katello_component_content_views", "katello_content_view_definition_bases",
                            :name => "component_content_views_content_view_definition_id_fk", :column => "content_view_definition_id"

    add_foreign_key "katello_content_view_definition_bases", "katello_content_view_definition_bases",
                            :name => "content_view_definition_bases_source_id_fk", :column => "source_id"

    add_foreign_key "katello_content_view_definition_products", "katello_content_view_definition_bases",
                            :name => "content_view_definition_products_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_content_view_definition_products", "katello_products",
                            :name => "content_view_definition_products_product_id_fk", :column => "product_id"
    add_foreign_key "katello_content_view_definition_repositories", "katello_content_view_definition_bases",
                            :name => "CV_definition_repositories_CV_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_content_view_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key "katello_content_view_versions", "katello_content_view_definition_bases", :name => "content_view_versions_definition_archive_id_fk", :column => "definition_archive_id"
    add_foreign_key "katello_content_views", "katello_content_view_definition_bases", :name => "content_views_content_view_definition_id_fk", :column => "content_view_definition_id"

    add_foreign_key "katello_filters", "katello_content_view_definition_bases", :name => "filters_content_view_definition_id_fk", :column => "content_view_definition_id"
    add_foreign_key "katello_filters_products", "katello_filters", :name => "filters_product_filter_id_fk", :column => 'filter_id'
    add_foreign_key "katello_filters_products", "katello_products", :name => "filters_product_product_id_fk", :column => "product_id"
    add_foreign_key "katello_filter_rules", "katello_filters", :name => "filters_rules_filter_id_fk", :column => 'filter_id'

  end
end
