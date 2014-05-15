class UpdateHostCollectionsForeignKeys < ActiveRecord::Migration
  def up
    remove_foreign_key "katello_key_host_collections", :name => "key_system_groups_activation_key_id_fk"
    remove_foreign_key "katello_key_host_collections", :name => "key_system_groups_system_group_id_fk"

    remove_foreign_key "katello_system_host_collections", :name => "system_system_groups_system_group_id_fk"
    remove_foreign_key "katello_system_host_collections", :name => "system_system_groups_system_id_fk"

    add_foreign_key "katello_key_host_collections", "katello_activation_keys", :name => "key_host_collections_activation_key_id_fk", :column => 'activation_key_id'
    add_foreign_key "katello_key_host_collections", "katello_host_collections", :name => "key_host_collections_host_collection_id_fk", :column => 'host_collection_id'

    add_foreign_key "katello_system_host_collections", "katello_host_collections", :name => "system_host_collections_host_collection_id_fk", :column => 'host_collection_id'
    add_foreign_key "katello_system_host_collections", "katello_systems", :name => "system_host_collections_system_id_fk", :column => 'system_id'
  end

  def down
    remove_foreign_key "katello_key_host_collections", :name => "key_host_collections_activation_key_id_fk"
    remove_foreign_key "katello_key_host_collections", :name => "key_host_collections_host_collection_id_fk"

    remove_foreign_key "katello_system_host_collections", :name => "system_host_collections_host_collection_id_fk"
    remove_foreign_key "katello_system_host_collections", :name => "system_host_collections_system_id_fk"

    add_foreign_key "katello_key_host_collections", "katello_activation_keys", :name => "key_system_groups_activation_key_id_fk", :column => 'activation_key_id'
    add_foreign_key "katello_key_host_collections", "katello_host_collections", :name => "key_system_groups_system_group_id_fk", :column => 'host_collection_id'

    add_foreign_key "katello_system_host_collections", "katello_host_collections", :name => "system_system_groups_system_group_id_fk", :column => 'host_collection_id'
    add_foreign_key "katello_system_host_collections", "katello_systems", :name => "system_system_groups_system_id_fk", :column => 'system_id'
  end
end
