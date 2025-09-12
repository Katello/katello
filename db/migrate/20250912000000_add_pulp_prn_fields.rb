class AddPulpPrnFields < ActiveRecord::Migration[7.0]
  # rubocop:disable Metrics/MethodLength
  def up
    # Tables with pulp_href fields - add pulp_prn field
    add_column :katello_content_guards, :pulp_prn, :string

    # Tables with pulp_id fields - add pulp_prn field
    add_column :katello_repositories, :pulp_prn, :string
    add_column :katello_ansible_collections, :pulp_prn, :string
    add_column :katello_generic_content_units, :pulp_prn, :string
    add_column :katello_module_streams, :pulp_prn, :string
    add_column :katello_docker_manifest_lists, :pulp_prn, :string
    add_column :katello_docker_manifests, :pulp_prn, :string
    add_column :katello_docker_tags, :pulp_prn, :string
    add_column :katello_errata, :pulp_prn, :string
    add_column :katello_rpms, :pulp_prn, :string
    add_column :katello_srpms, :pulp_prn, :string
    add_column :katello_files, :pulp_prn, :string # FileUnit uses table_name 'katello_files'
    add_column :katello_package_groups, :pulp_prn, :string
    add_column :katello_debs, :pulp_prn, :string

    # Tables with other href fields - add corresponding _prn fields
    add_column :katello_repositories, :remote_prn, :string
    add_column :katello_repositories, :publication_prn, :string
    add_column :katello_repositories, :version_prn, :string
    add_column :katello_distribution_references, :prn, :string
    add_column :katello_distribution_references, :content_guard_prn, :string
    add_column :katello_repository_references, :repository_prn, :string
    add_column :katello_repository_errata, :erratum_prn, :string
    add_column :katello_smart_proxy_alternate_content_sources, :remote_prn, :string
    add_column :katello_smart_proxy_alternate_content_sources, :alternate_content_source_prn, :string

    # Add indexes for performance on commonly queried fields
    add_index :katello_content_guards, :pulp_prn
    add_index :katello_repositories, :pulp_prn
    add_index :katello_repositories, :remote_prn
    add_index :katello_repositories, :publication_prn
    add_index :katello_repositories, :version_prn
    add_index :katello_ansible_collections, :pulp_prn
    add_index :katello_generic_content_units, :pulp_prn
    add_index :katello_module_streams, :pulp_prn
    add_index :katello_docker_manifest_lists, :pulp_prn
    add_index :katello_docker_manifests, :pulp_prn
    add_index :katello_docker_tags, :pulp_prn
    add_index :katello_errata, :pulp_prn
    add_index :katello_rpms, :pulp_prn
    add_index :katello_srpms, :pulp_prn
    add_index :katello_files, :pulp_prn
    add_index :katello_package_groups, :pulp_prn
    add_index :katello_debs, :pulp_prn
    add_index :katello_repository_errata, :erratum_prn
  end

  def down
    # Remove indexes
    remove_index :katello_content_guards, :pulp_prn
    remove_index :katello_repositories, :pulp_prn
    remove_index :katello_repositories, :remote_prn
    remove_index :katello_repositories, :publication_prn
    remove_index :katello_repositories, :version_prn
    remove_index :katello_ansible_collections, :pulp_prn
    remove_index :katello_generic_content_units, :pulp_prn
    remove_index :katello_module_streams, :pulp_prn
    remove_index :katello_docker_manifest_lists, :pulp_prn
    remove_index :katello_docker_manifests, :pulp_prn
    remove_index :katello_docker_tags, :pulp_prn
    remove_index :katello_errata, :pulp_prn
    remove_index :katello_rpms, :pulp_prn
    remove_index :katello_srpms, :pulp_prn
    remove_index :katello_files, :pulp_prn
    remove_index :katello_package_groups, :pulp_prn
    remove_index :katello_debs, :pulp_prn
    remove_index :katello_repository_errata, :erratum_prn

    # Remove columns - pulp_prn fields
    remove_column :katello_content_guards, :pulp_prn
    remove_column :katello_repositories, :pulp_prn
    remove_column :katello_ansible_collections, :pulp_prn
    remove_column :katello_generic_content_units, :pulp_prn
    remove_column :katello_module_streams, :pulp_prn
    remove_column :katello_docker_manifest_lists, :pulp_prn
    remove_column :katello_docker_manifests, :pulp_prn
    remove_column :katello_docker_tags, :pulp_prn
    remove_column :katello_errata, :pulp_prn
    remove_column :katello_rpms, :pulp_prn
    remove_column :katello_srpms, :pulp_prn
    remove_column :katello_files, :pulp_prn
    remove_column :katello_package_groups, :pulp_prn
    remove_column :katello_debs, :pulp_prn

    # Remove columns - other _prn fields
    remove_column :katello_repositories, :remote_prn
    remove_column :katello_repositories, :publication_prn
    remove_column :katello_repositories, :version_prn
    remove_column :katello_distribution_references, :prn
    remove_column :katello_distribution_references, :content_guard_prn
    remove_column :katello_repository_references, :repository_prn
    remove_column :katello_repository_errata, :erratum_prn
    remove_column :katello_smart_proxy_alternate_content_sources, :remote_prn
    remove_column :katello_smart_proxy_alternate_content_sources, :alternate_content_source_prn
  end
  # rubocop:enable Metrics/MethodLength
end
