module Katello
  module Pulp
    class Repository
      class Yum < ::Katello::Pulp::Repository
        def generate_master_importer
          config = {
            download_policy: root.download_policy,
            remove_missing: root.mirror_on_sync?,
            feed: root.url,
            type_skip_list: root.ignorable_content
          }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            download_policy: smart_proxy_download_policy,
            remove_missing: true,
            feed: external_url(true)
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def partial_repo_path
          "/pulp/repos/#{repo.relative_path}/".sub('//', '/')
        end

        def importer_class
          Runcible::Models::YumImporter
        end

        def generate_distributors
          yum_dist_id = repo.pulp_id
          options = {
            protected: true,
            id: yum_dist_id,
            auto_publish: true
          }
          if smart_proxy.pulp_master?
            options[:checksum_type] = repo.saved_checksum_type || root.checksum_type
          else
            options[:checksum_type] = nil
          end
          distributors = [Runcible::Models::YumDistributor.new(repo.relative_path, root.unprotected, true, options)]

          if smart_proxy.pulp_master?
            distributors << Runcible::Models::YumCloneDistributor.new(:id => "#{repo.pulp_id}_clone",
                                                                   :destination_distributor_id => yum_dist_id)
            distributors << Runcible::Models::ExportDistributor.new(false, false, repo.relative_path)
          end
          distributors
        end

        def distributors_to_publish(_options)
          if repo.clone && !repo.master?
            source_service = repo.target_repository.backend_service(smart_proxy)
            source_distributor_id = source_service.lookup_distributor_id(Runcible::Models::YumDistributor.type_id)
            {Runcible::Models::YumCloneDistributor => {source_repo_id: repo.target_repository.pulp_id,
                                                       source_distributor_id: source_distributor_id}}
          else
            {Runcible::Models::YumDistributor => {}}
          end
        end

        def smart_proxy_download_policy
          policy = smart_proxy.download_policy || Setting[:default_proxy_download_policy]
          if policy == ::SmartProxy::DOWNLOAD_INHERIT
            self.root.download_policy
          else
            policy
          end
        end

        def regenerate_applicability
          smart_proxy.pulp_api.extensions.repository.regenerate_applicability_by_ids([repo.pulp_id], true)
        end

        def copy_contents(destination_repo, options = {})
          override_config = Katello::Repository.build_override_config(options)
          rpm_copy_clauses, rpm_remove_clauses = generate_copy_clauses(options[:filters]&.yum(false), options[:rpm_filenames])
          tasks = [smart_proxy.pulp_api.extensions.rpm.copy(repo.pulp_id, destination_repo.pulp_id,
                   rpm_copy_clauses.merge(:override_config => override_config))]

          if rpm_remove_clauses
            tasks << smart_proxy.pulp_api.extensions.repository.unassociate_units(destination_repo.pulp_id,
                                                                         type_ids: [::Katello::Pulp::Rpm::CONTENT_TYPE],
                                                                          filters: {unit: rpm_remove_clauses})
          end

          tasks.concat(copy_module_contents(destination_repo, options[:filters]&.module_stream, override_config))
          [:srpm, :errata, :package_group, :package_environment,
           :yum_repo_metadata_file, :distribution, :module_default].each do |type|
            tasks << smart_proxy.pulp_api.extensions.send(type).copy(repo.pulp_id, destination_repo.pulp_id)
          end
          tasks
        end

        def import_distribution_data
          distribution = smart_proxy.pulp_api.extensions.repository.distributions(repo.pulp_id).first
          if distribution
            repo.update_attributes!(
              :distribution_version => distribution["version"],
              :distribution_arch => distribution["arch"],
              :distribution_family => distribution["family"],
              :distribution_variant => distribution["variant"],
              :distribution_uuid => distribution["_id"],
              :distribution_bootable => self.class.distribution_bootable?(distribution)
            )
          end
        end

        def self.distribution_bootable?(distribution)
          # Not every distribution from Pulp represents a bootable
          # repo. Determine based on the files in the repo.
          distribution["files"].any? do |file|
            if file.is_a? Hash
              filename = file[:relativepath]
            else
              filename = file
            end
            filename.include?('vmlinuz') || filename.include?('pxeboot') || filename.include?('kernel.img') || filename.include?('initrd.img')
          end
        end

        def purge_empty_contents
          [purge_partial_errata, purge_empty_package_groups]
        end

        def should_purge_empty_contents?
          true
        end

        def purge_partial_errata
          task = nil
          repo.remove_partial_errata! do |errata_to_delete|
            task = repo.unassociate_by_filter(::Katello::ContentViewErratumFilter::CONTENT_TYPE,
                                                "id" => { "$in" => errata_to_delete.map(&:errata_id) })
          end
          task
        end

        private

        def purge_empty_package_groups
          rpm_names = repo.rpms.pluck(:name).uniq

          # Remove all  package groups with no packages
          package_groups_to_delete = repo.package_groups.select do |group|
            (rpm_names & group.package_names).empty?
          end

          repo.repository_package_groups.where(:package_group_id => package_groups_to_delete.map(&:id)).delete_all

          criteria = {:association => {"unit_id" => {"$in" => package_groups_to_delete.compact}}}
          smart_proxy.pulp_api.extensions.repository.unassociate_units(repo.pulp_id, :filters => criteria)
        end

        def copy_module_contents(destination_repo, filters, override_config)
          copy_clauses, remove_clauses = generate_module_stream_copy_clauses(filters)
          tasks = [smart_proxy.pulp_api.extensions.module.copy(repo.pulp_id, destination_repo.pulp_id,
                   copy_clauses.merge(:override_config => override_config))]

          if remove_clauses
            tasks << smart_proxy.pulp_api.extensions.repository.unassociate_units(destination_repo.pulp_id,
                                                                         type_ids: [::Katello::Pulp::ModuleStream::CONTENT_TYPE],
                                                                          filters: {unit: remove_clauses})
          end
          tasks
        end

        def generate_module_stream_copy_clauses(filters)
          if filters&.any?
            clause_gen = ::Katello::Util::ModuleStreamClauseGenerator.new(repo, filters.module_stream)
            clause_gen.generate

            copy = clause_gen.copy_clause
            copy_clauses = {filters: {unit: copy }} if copy

            remove = clause_gen.remove_clause
            remove_clauses = {filters: {unit: remove}} if remove
          else
            copy_clauses = {}
            remove_clauses = nil
          end
          [copy_clauses, remove_clauses]
        end

        def generate_copy_clauses(filters, rpm_filenames)
          if rpm_filenames&.any?
            copy_clauses = {filters: {unit: { 'filename' => { '$in' => rpm_filenames } }}}
            remove_clauses = nil
          elsif filters&.any?
            clause_gen = ::Katello::Util::PackageClauseGenerator.new(repo, filters.yum(false))
            clause_gen.generate

            copy = clause_gen.copy_clause
            copy_clauses = {filters: {unit: copy }} if copy

            remove = clause_gen.remove_clause
            remove_clauses = {filters: {unit: remove}} if remove
          else
            copy_clauses = {filters: {unit: ContentViewPackageFilter.generate_rpm_clauses(::Katello::Rpm.in_repositories(repo).non_modular.pluck(:filename))}}
            remove_clauses = nil
          end

          copy_clauses.merge!(fields: ::Katello::Pulp::Rpm::PULP_SELECT_FIELDS)
          [copy_clauses, remove_clauses]
        end
      end
    end
  end
end
