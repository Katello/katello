class CreateHostgroupContentFacet < ActiveRecord::Migration[5.1]
  def change
    create_table :katello_hostgroup_content_facets do |t|
      t.column :hostgroup_id, :integer, :null => false
      t.column :kickstart_repository_id, :integer, :null => true
      t.column :content_source_id, :integer, :null => true
      t.column :content_view_id, :integer, :null => true
      t.column :lifecycle_environment_id, :integer, :null => true
    end
    add_foreign_key :katello_hostgroup_content_facets, :katello_repositories, :column => :kickstart_repository_id
    add_foreign_key :katello_hostgroup_content_facets, :hostgroups, :column => :hostgroup_id
    add_foreign_key :katello_hostgroup_content_facets, :katello_content_views, :column => :content_view_id
    add_foreign_key :katello_hostgroup_content_facets, :smart_proxies, :name => "katello_hostgroup_content_facets_content_source_id_fk", :column => "content_source_id"
    add_foreign_key :katello_hostgroup_content_facets, :katello_environments, :column => :lifecycle_environment_id
  end
end
