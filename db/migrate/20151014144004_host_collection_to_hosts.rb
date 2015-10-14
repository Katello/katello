class HostCollectionToHosts < ActiveRecord::Migration
  class Host < ActiveRecord::Base
    self.table_name = "hosts"
  end

  class System < ActiveRecord::Base
    self.table_name = "katello_systems"
  end

  class HostCollection < ActiveRecord::Base
    self.table_name = "katello_host_collections"
  end

  class SystemHostCollections < ActiveRecord::Base
    self.table_name = "katello_system_host_collections"
  end

  class HostCollectionHosts < ActiveRecord::Base
    self.table_name = "katello_host_collection_hosts"
  end

  def logger
    Rails.logger
  end

  def create_host_collection_hosts_table
    create_table :katello_host_collection_hosts, :force => true do |t|
      t.references :host_collection
      t.references :host
      t.timestamps
    end

    add_foreign_key "katello_host_collection_hosts", "katello_host_collections",
                    :name => "katello_host_collection_hosts_host_collection_id_fk", :column => "host_collection_id"

    add_foreign_key "katello_host_collection_hosts", "hosts",
                    :name => "katello_host_collection_hosts_host_id_fk", :column => "host_id"

    add_index :katello_host_collection_hosts, [:host_collection_id]
    add_index :katello_host_collection_hosts, [:host_id]
  end

  def create_system_host_collections
    create_table :katello_system_host_collections, :force => true do |t|
      t.integer  "system_id"
      t.integer  "host_collection_id"
      t.timestamps
    end

    add_foreign_key "katello_system_host_collections", "katello_host_collections",
                    :name => "katello_system_host_collections_host_collection_id_fk", :column => "host_collection_id"

    add_foreign_key "katello_system_host_collections", "katello_systems",
                    :name => "katello_system_host_collections_host_id_fk", :column => "system_id"

    add_index :katello_system_host_collections, [:host_collection_id]
    add_index :katello_system_host_collections, [:system_id]
  end

  def up
    create_host_collection_hosts_table

    SystemHostCollections.all.each do |system_host_collection|
      system = System.find(system_host_collection.system_id)
      host_collection = HostCollection.find(system_host_collection.host_collection_id)

      host_collection_host = HostCollectionHosts.new(:host_id => system.host_id, :host_collection_id => host_collection.id)
      host_collection_host.save!
    end

    drop_table :katello_system_host_collections

    rename_column :katello_host_collections, :max_content_hosts, :max_hosts
    rename_column :katello_host_collections, :unlimited_content_hosts, :unlimited_hosts
  end

  def down
    create_system_host_collections

    HostCollectionHosts.all.each do |host_collection_host|
      system = System.where(:host_id => host_collection_host.host_id).first
      host_collection = HostCollection.find(host_collection_host.host_collection_id)

      system_host_collection = SystemHostCollections.new(:system_id => system.id, :host_collection_id => host_collection.id)
      system_host_collection.save!
    end

    drop_table :katello_host_collection_hosts

    rename_column :katello_host_collections, :max_hosts, :max_content_hosts
    rename_column :katello_host_collections, :unlimited_hosts, :unlimited_content_hosts
  end
end
