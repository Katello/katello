class RenameSystemGroupsToHostCollections < ActiveRecord::Migration
  def change
    rename_index :katello_key_system_groups, "index_key_system_groups_on_activation_key_id", "index_key_host_collections_on_activation_key_id"
    rename_index :katello_key_system_groups, "index_key_system_groups_on_system_group_id", "index_key_host_collections_on_host_collection_id"

    remove_foreign_key :katello_key_system_groups, :name => "key_system_groups_system_group_id_fk"

    rename_column :katello_key_system_groups, :system_group_id, :host_collection_id
    rename_table :katello_key_system_groups, :katello_key_host_collections

    rename_index :katello_system_groups, "index_system_groups_on_name_and_organization_id", "index_host_collections_on_name_and_organization_id"
    rename_index :katello_system_groups, "index_system_groups_on_organization_id", "index_host_collections_on_organization_id"
    rename_column :katello_system_groups, :max_systems, :max_content_hosts
    rename_table :katello_system_groups, :katello_host_collections

    add_foreign_key :katello_key_host_collections, :katello_host_collections, :name => "key_system_groups_system_group_id_fk", :column => "host_collection_id"

    rename_index :katello_system_system_groups, "index_system_system_groups_on_system_group_id", "index_system_host_collections_on_host_collection_id"
    rename_index :katello_system_system_groups, "index_system_system_groups_on_system_id", "index_system_host_collections_on_system_id"
    remove_foreign_key :katello_system_system_groups, :name => "system_system_groups_system_group_id_fk"
    rename_column :katello_system_system_groups, :system_group_id, :host_collection_id
    rename_table :katello_system_system_groups, :katello_system_host_collections
    add_foreign_key :katello_system_host_collections, :katello_host_collections, :name => "system_system_groups_system_group_id_fk", :column => "host_collection_id"
  end
end
