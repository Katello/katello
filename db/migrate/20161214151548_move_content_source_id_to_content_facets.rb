class MoveContentSourceIdToContentFacets < ActiveRecord::Migration
  def up
    add_column :katello_content_facets, :content_source_id, :integer
    add_index :katello_content_facets, :content_source_id
    add_foreign_key :katello_content_facets, :smart_proxies, :name => "katello_content_facets_content_source_id_fk", :column => "content_source_id"

    Host.find_each do |host|
      content_facet = host.content_facet
      if content_facet && host.content_source_id
        content_facet.content_source_id = host.content_source_id
        content_facet.save!
      end
    end

    remove_foreign_key :hosts, :name => "hosts_content_source_id_fk"
    remove_index :hosts, :content_source_id
    remove_column :hosts, :content_source_id
  end

  def down
    add_column :hosts, :content_source_id, :integer
    add_index :hosts, :content_source_id
    add_foreign_key :hosts, :smart_proxies, :name => "hosts_content_source_id_fk", :column => "content_source_id"

    Host.find_each do |host|
      if host.content_facet
        host.content_source_id = host.content_facet.content_source_id
        if host.content_facet.content_source
          host.save!
        end
      end
    end

    remove_foreign_key :katello_content_facets, :name => "katello_content_facets_content_source_id_fk"
    remove_index :katello_content_facets, :content_source_id
    remove_column :katello_content_facets, :content_source_id
  end
end
