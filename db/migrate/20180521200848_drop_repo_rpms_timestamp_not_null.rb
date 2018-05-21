class DropRepoRpmsTimestampNotNull < ActiveRecord::Migration[5.1]
  def change
    tables = [:katello_repository_docker_manifest_lists,
              :katello_repository_docker_manifests,
              :katello_repository_errata,
              :katello_repository_files,
              :katello_repository_ostree_branches,
              :katello_repository_package_groups,
              :katello_repository_puppet_modules,
              :katello_repository_rpms,
              :katello_repository_srpms]

    tables.each do |table|
      change_column table, :created_at, :datetime, :null => true
      change_column table, :updated_at, :datetime, :null => true
    end
  end
end
