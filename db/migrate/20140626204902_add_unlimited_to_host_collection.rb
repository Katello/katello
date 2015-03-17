class AddUnlimitedToHostCollection < ActiveRecord::Migration
  class ::Katello::HostCollections < ActiveRecord::Base
  end

  def up
    add_column :katello_host_collections, :unlimited_content_hosts, :boolean, :default => true
    change_column :katello_host_collections, :max_content_hosts, :integer, :null => true, :default => nil

    Katello::HostCollections.reset_column_information
    Katello::HostCollections.all.each do |coll|
      if coll.max_content_hosts == -1
        coll.update_attributes(:unlimited_content_hosts => true, :max_content_hosts => nil)
      elsif coll.max_content_hosts > 0
        coll.update_attributes(:unlimited_content_hosts => false)
      end
    end
  end

  def down
    Katello::HostCollections.all.each do |coll|
      coll.update_attributes(:max_content_hosts => -1) if coll.unlimited_content_hosts
    end

    remove_column :katello_host_collections, :unlimited_content_hosts
    change_column :katello_host_collections, :max_content_hosts, :integer, :null => false, :default => -1
  end
end
