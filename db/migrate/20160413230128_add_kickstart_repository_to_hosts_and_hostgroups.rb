class AddKickstartRepositoryToHostsAndHostgroups < ActiveRecord::Migration
  def change
    add_column :katello_content_facets, :kickstart_repository_id, :integer, :null => true
    add_foreign_key :katello_content_facets, :katello_repositories, :column => :kickstart_repository_id

    add_column :hostgroups, :kickstart_repository_id, :integer, :null => true
    add_foreign_key :hostgroups, :katello_repositories, :column => :kickstart_repository_id
  end
end
