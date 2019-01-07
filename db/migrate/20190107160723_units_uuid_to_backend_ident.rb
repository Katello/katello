class UnitsUuidToBackendIdent < ActiveRecord::Migration[5.2]
  def change
    %w(rpms errata package_groups files yum_metadata_files srpms module_streams debs docker_tags docker_manifests
       docker_manifest_lists puppet_modules ostree_branches).each do |name|
      rename_column("katello_#{name}", :uuid, :pulp_id)
    end
  end
end
