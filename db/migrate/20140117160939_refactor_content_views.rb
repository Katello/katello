class RefactorContentViews < ActiveRecord::Migration
  def up
    drop_table :katello_content_view_definition_bases
    drop_table :katello_content_view_definition_products
    drop_table :katello_filters_products
    drop_table :katello_filter_rules

    add_column :katello_content_views, :composite, :boolean
    remove_column :katello_content_views, :content_view_definition_id

    rename_column :katello_component_content_views, :content_view_definition_id, :component_content_view_id

    rename_table :katello_content_view_definition_repositories, :katello_content_view_repositories
    rename_column :katello_content_view_repositories, :content_view_definition_id, :content_view_id

    # katello filters
    rename_column :katello_filters, :content_view_definition_id, :content_view_id
    add_column :katello_filters, :all_repositories, :boolean
    add_column :katello_filters, :type, :string
    add_column :katello_filters, :parameters, :text
    add_column :katello_filters, :inclusion, :boolean

    # TODO: content view archival

    # TODO: add foreign keys
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

    remove_column :katello_content_views, :composite
    add_column :katello_content_views, :content_view_definition_id, :integer

    rename_column :katello_component_content_views, :component_content_view_id, :content_view_definition_id

    rename_column :katello_content_view_repositories, :content_view_id, :content_view_definition_id
    rename_table :katello_content_view_repositories, :katello_content_view_definition_repositories

    rename_column :katello_filters, :content_view_id, :content_view_definition_id
    remove_column :katello_filters, :all_repositories
    remove_column :katello_filters, :type
    remove_column :katello_filters, :parameters
    remove_column :katello_filters, :inclusion
  end
end
