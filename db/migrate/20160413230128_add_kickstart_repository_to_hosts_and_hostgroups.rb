class AddKickstartRepositoryToHostsAndHostgroups < ActiveRecord::Migration
  def change
    add_column :hosts, :kickstart_repository_id, :integer, :null => true
    add_foreign_key :hosts, :katello_repositories, :column => :kickstart_repository_id

    add_column :hostgroups, :kickstart_repository_id, :integer, :null => true
    add_foreign_key :hostgroups, :katello_repositories, :column => :kickstart_repository_id
  end
end
