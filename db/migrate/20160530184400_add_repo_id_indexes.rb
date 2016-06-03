class AddRepoIdIndexes < ActiveRecord::Migration
  def change
    add_index :katello_repository_docker_manifests, :repository_id
    add_index :katello_repository_errata, :repository_id
    add_index :katello_repository_ostree_branches, :repository_id
    add_index :katello_repository_package_groups, :repository_id
    add_index :katello_repository_puppet_modules, :repository_id
    add_index :katello_repository_rpms, :repository_id
  end
end
