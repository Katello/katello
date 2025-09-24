# rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/ClassLength
class PopulatePulpPrnFields < ActiveRecord::Migration[7.0]
  def up
    # Content Guards - RHSM cert guards
    Katello::Pulp3::ContentGuard.where.not(pulp_href: nil).update_all(
      "pulp_prn = CASE
        WHEN pulp_href ~ '/contentguards/certguard/rhsm/' THEN
          'prn:certguard.rhsmcertguard:' ||
          regexp_replace(pulp_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Repositories - remote_prn
    Katello::Repository.where.not(remote_href: nil).update_all(
      "remote_prn = CASE
        WHEN remote_href ~ '/remotes/rpm/rpm/' THEN
          'prn:rpm.rpmremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/rpm/uln/' THEN
          'prn:rpm.ulnremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/deb/apt/' THEN
          'prn:deb.aptremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/container/container/' THEN
          'prn:container.containerremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/ansible/collection/' THEN
          'prn:ansible.collectionremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/python/python/' THEN
          'prn:python.pythonremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/file/file/' THEN
          'prn:file.fileremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/ostree/ostree/' THEN
          'prn:ostree.ostreeremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Repositories - publication_prn
    Katello::Repository.where.not(publication_href: nil).update_all(
      "publication_prn = CASE
        WHEN publication_href ~ '/publications/rpm/rpm/' THEN
          'prn:rpm.rpmpublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        WHEN publication_href ~ '/publications/deb/apt/' THEN
          'prn:deb.aptpublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        WHEN publication_href ~ '/publications/container/container/' THEN
          'prn:container.containerpublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        WHEN publication_href ~ '/publications/ansible/ansible/' THEN
          'prn:ansible.ansiblepublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        WHEN publication_href ~ '/publications/python/pypi/' THEN
          'prn:python.pythonpublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        WHEN publication_href ~ '/publications/file/file/' THEN
          'prn:file.filepublication:' ||
          regexp_replace(publication_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Ansible Collections - Process in batches due to potentially large number of records
    Katello::AnsibleCollection.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/ansible/collection_versions/' THEN
            'prn:ansible.collectionversion:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Generic Content Units - Process in batches due to potentially large number of records
    Katello::GenericContentUnit.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/python/packages/' THEN
            'prn:python.pythonpackagecontent:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          WHEN pulp_id ~ '/content/ostree/refs/' THEN
            'prn:ostree.ostreeref:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Module Streams - Process in batches due to potentially large number of records
    Katello::ModuleStream.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/rpm/modulemds/' THEN
            'prn:rpm.modulemd:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Docker Manifest Lists - Process in batches due to potentially large number of records
    Katello::DockerManifestList.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/container/manifests/' THEN
            'prn:container.manifest:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Docker Manifests - Process in batches due to potentially large number of records
    Katello::DockerManifest.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/container/manifests/' THEN
            'prn:container.manifest:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Docker Tags - Process in batches due to potentially large number of records
    Katello::DockerTag.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/container/tags/' THEN
            'prn:container.tag:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # RPMs - Process in batches due to potentially millions of records
    Katello::Rpm.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/rpm/packages/' THEN
            'prn:rpm.package:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # SRPMs - Process in batches due to potentially large number of records
    Katello::Srpm.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/rpm/packages/' THEN
            'prn:rpm.package:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Files (FileUnit uses table_name 'katello_files') - Process in batches due to potentially large number of records
    Katello::FileUnit.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/file/files/' THEN
            'prn:file.filecontent:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Package Groups - Process in batches due to potentially large number of records
    Katello::PackageGroup.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/rpm/packagegroups/' THEN
            'prn:rpm.packagegroup:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Debs - Process in batches due to potentially large number of records
    Katello::Deb.where.not(pulp_id: nil).in_batches(of: 10_000) do |batch|
      batch.update_all(
        "pulp_prn = CASE
          WHEN pulp_id ~ '/content/deb/packages/' THEN
            'prn:deb.package:' ||
            regexp_replace(pulp_id, '^.*/([^/]+)/?$', '\\1')
          ELSE NULL
        END"
      )
    end

    # Distribution References - prn
    Katello::Pulp3::DistributionReference.where.not(href: nil).update_all(
      "prn = CASE
        WHEN href ~ '/distributions/rpm/rpm/' THEN
          'prn:rpm.rpmdistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/deb/apt/' THEN
          'prn:deb.aptdistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/container/container/' THEN
          'prn:container.containerdistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/ansible/ansible/' THEN
          'prn:ansible.ansibledistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/python/pypi/' THEN
          'prn:python.pythondistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/file/file/' THEN
          'prn:file.filedistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        WHEN href ~ '/distributions/ostree/ostree/' THEN
          'prn:ostree.ostreedistribution:' ||
          regexp_replace(href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Distribution References - content_guard_prn
    Katello::Pulp3::DistributionReference.where.not(content_guard_href: nil).update_all(
      "content_guard_prn = CASE
        WHEN content_guard_href ~ '/contentguards/certguard/rhsm/' THEN
          'prn:certguard.rhsmcertguard:' ||
          regexp_replace(content_guard_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Repository References - repository_prn
    Katello::Pulp3::RepositoryReference.where.not(repository_href: nil).update_all(
      "repository_prn = CASE
        WHEN repository_href ~ '/repositories/rpm/rpm/' THEN
          'prn:rpm.rpmrepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/deb/apt/' THEN
          'prn:deb.aptrepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/container/container/' THEN
          'prn:container.containerrepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/ansible/ansible/' THEN
          'prn:ansible.ansiblerepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/python/python/' THEN
          'prn:python.pythonrepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/file/file/' THEN
          'prn:file.filerepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        WHEN repository_href ~ '/repositories/ostree/ostree/' THEN
          'prn:ostree.ostreerepository:' ||
          regexp_replace(repository_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Repository Errata - erratum_prn
    Katello::RepositoryErratum.where.not(erratum_pulp3_href: nil).update_all(
      "erratum_prn = CASE
        WHEN erratum_pulp3_href ~ '/content/rpm/advisories/' THEN
          'prn:rpm.updaterecord:' ||
          regexp_replace(erratum_pulp3_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Smart Proxy Alternate Content Sources - remote_prn
    Katello::SmartProxyAlternateContentSource.where.not(remote_href: nil).update_all(
      "remote_prn = CASE
        WHEN remote_href ~ '/remotes/rpm/rpm/' THEN
          'prn:rpm.rpmremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/rpm/uln/' THEN
          'prn:rpm.ulnremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/deb/apt/' THEN
          'prn:deb.aptremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/container/container/' THEN
          'prn:container.containerremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/ansible/collection/' THEN
          'prn:ansible.collectionremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/python/python/' THEN
          'prn:python.pythonremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        WHEN remote_href ~ '/remotes/file/file/' THEN
          'prn:file.fileremote:' ||
          regexp_replace(remote_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # Smart Proxy Alternate Content Sources - alternate_content_source_prn
    Katello::SmartProxyAlternateContentSource.where.not(alternate_content_source_href: nil).update_all(
      "alternate_content_source_prn = CASE
        WHEN alternate_content_source_href ~ '/acs/rpm/rpm/' THEN
          'prn:rpm.rpmalternatecontentsource:' ||
          regexp_replace(alternate_content_source_href, '^.*/([^/]+)/?$', '\\1')
        WHEN alternate_content_source_href ~ '/acs/file/file/' THEN
          'prn:file.filealternatecontentsource:' ||
          regexp_replace(alternate_content_source_href, '^.*/([^/]+)/?$', '\\1')
        ELSE NULL
      END"
    )

    # # Add NOT NULL constraints to PRN fields that correspond to required href fields
    # # These constraints match the NOT NULL constraints on their corresponding href fields
    # change_column_null :katello_content_guards, :pulp_prn, false
    # change_column_null :katello_repository_references, :repository_prn, false
    #
    # # Add NOT NULL constraints to all pulp_prn fields for content tables
    # change_column_null :katello_ansible_collections, :pulp_prn, false
    # change_column_null :katello_generic_content_units, :pulp_prn, false
    # change_column_null :katello_module_streams, :pulp_prn, false
    # change_column_null :katello_docker_manifest_lists, :pulp_prn, false
    # change_column_null :katello_docker_manifests, :pulp_prn, false
    # change_column_null :katello_docker_tags, :pulp_prn, false
    # change_column_null :katello_rpms, :pulp_prn, false
    # change_column_null :katello_srpms, :pulp_prn, false
    # change_column_null :katello_files, :pulp_prn, false
    # change_column_null :katello_package_groups, :pulp_prn, false
    # change_column_null :katello_debs, :pulp_prn, false
    #
    # # Add unique indexes for all pulp_prn fields for content tables
    # add_index :katello_ansible_collections, :pulp_prn, unique: true
    # add_index :katello_generic_content_units, :pulp_prn, unique: true
    # add_index :katello_module_streams, :pulp_prn, unique: true
    # add_index :katello_docker_manifest_lists, :pulp_prn, unique: true
    # add_index :katello_docker_manifests, :pulp_prn, unique: true
    # add_index :katello_docker_tags, :pulp_prn, unique: true
    # add_index :katello_rpms, :pulp_prn, unique: true
    # add_index :katello_srpms, :pulp_prn, unique: true
    # add_index :katello_files, :pulp_prn, unique: true
    # add_index :katello_package_groups, :pulp_prn, unique: true
    # add_index :katello_debs, :pulp_prn, unique: true
  end

  def down
    # # Remove unique indexes before clearing data
    # remove_index :katello_ansible_collections, :pulp_prn
    # remove_index :katello_generic_content_units, :pulp_prn
    # remove_index :katello_module_streams, :pulp_prn
    # remove_index :katello_docker_manifest_lists, :pulp_prn
    # remove_index :katello_docker_manifests, :pulp_prn
    # remove_index :katello_docker_tags, :pulp_prn
    # remove_index :katello_rpms, :pulp_prn
    # remove_index :katello_srpms, :pulp_prn
    # remove_index :katello_files, :pulp_prn
    # remove_index :katello_package_groups, :pulp_prn
    # remove_index :katello_debs, :pulp_prn
    #
    # # Remove NOT NULL constraints before clearing data
    # change_column_null :katello_content_guards, :pulp_prn, true
    # change_column_null :katello_repository_references, :repository_prn, true
    # change_column_null :katello_ansible_collections, :pulp_prn, true
    # change_column_null :katello_generic_content_units, :pulp_prn, true
    # change_column_null :katello_module_streams, :pulp_prn, true
    # change_column_null :katello_docker_manifest_lists, :pulp_prn, true
    # change_column_null :katello_docker_manifests, :pulp_prn, true
    # change_column_null :katello_docker_tags, :pulp_prn, true
    # change_column_null :katello_rpms, :pulp_prn, true
    # change_column_null :katello_srpms, :pulp_prn, true
    # change_column_null :katello_files, :pulp_prn, true
    # change_column_null :katello_package_groups, :pulp_prn, true
    # change_column_null :katello_debs, :pulp_prn, true

    # Clear all PRN fields
    execute "UPDATE katello_content_guards SET pulp_prn = NULL"
    execute "UPDATE katello_repositories SET remote_prn = NULL, publication_prn = NULL, version_prn = NULL"
    execute "UPDATE katello_ansible_collections SET pulp_prn = NULL"
    execute "UPDATE katello_generic_content_units SET pulp_prn = NULL"
    execute "UPDATE katello_module_streams SET pulp_prn = NULL"
    execute "UPDATE katello_docker_manifest_lists SET pulp_prn = NULL"
    execute "UPDATE katello_docker_manifests SET pulp_prn = NULL"
    execute "UPDATE katello_docker_tags SET pulp_prn = NULL"
    execute "UPDATE katello_rpms SET pulp_prn = NULL"
    execute "UPDATE katello_srpms SET pulp_prn = NULL"
    execute "UPDATE katello_files SET pulp_prn = NULL"
    execute "UPDATE katello_package_groups SET pulp_prn = NULL"
    execute "UPDATE katello_debs SET pulp_prn = NULL"
    execute "UPDATE katello_distribution_references SET prn = NULL, content_guard_prn = NULL"
    execute "UPDATE katello_repository_references SET repository_prn = NULL"
    execute "UPDATE katello_repository_errata SET erratum_prn = NULL"
    execute "UPDATE katello_smart_proxy_alternate_content_sources SET remote_prn = NULL, alternate_content_source_prn = NULL"
  end
end
# rubocop:enable Metrics/MethodLength, Metrics/AbcSize, Metrics/ClassLength
