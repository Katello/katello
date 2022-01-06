module Katello
  module Pulp
    class Repository
      class Yum < ::Katello::Pulp::Repository
        REPOSITORY_TYPE = 'yum'.freeze

        def generate_primary_importer
          config = {
            download_policy: root.download_policy,
            remove_missing: root.mirror_on_sync?,
            feed: root.url,
            type_skip_list: root.ignorable_content
          }
          importer_class.new(config.merge(primary_importer_connection_options))
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
          # TODO: get /pulp/content from pulp_content_url
          "/pulp/content/#{repo.relative_path}/".sub('//', '/')
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
          if smart_proxy.pulp_primary?
            options[:checksum_type] = repo.saved_checksum_type || root.checksum_type
          else
            options[:checksum_type] = nil
          end
          distributors = [Runcible::Models::YumDistributor.new(repo.relative_path, root.unprotected, true, options)]

          if smart_proxy.pulp_primary?
            distributors << Runcible::Models::YumCloneDistributor.new(:id => "#{repo.pulp_id}_clone",
                                                                   :destination_distributor_id => yum_dist_id)
            distributors << Runcible::Models::ExportDistributor.new(false, false, repo.relative_path)
          end
          distributors
        end

        def distributors_to_publish(options)
          source_repo_id = options[:source_repository]&.fetch(:id)
          if (source_repo_id || !repo.primary?) && smart_proxy.pulp_primary?
            source_repository = source_repo_id ? ::Katello::Repository.find(source_repo_id) : repo.target_repository
            source_service = source_repository.backend_service(smart_proxy)
            source_distributor_id = source_service.lookup_distributor_id(Runcible::Models::YumDistributor.type_id)
            {Runcible::Models::YumCloneDistributor => {source_repo_id: source_repository.pulp_id,
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

        def generate_mapping(destination_repo)
          source_repo_map = {}
          repo.siblings.yum_type.each do |sibling|
            key = sibling.library_instance? ? sibling.id : sibling.library_instance_id
            source_repo_map[key] = sibling.pulp_id
          end

          Hash[destination_repo.siblings.yum_type.map { |sibling| [source_repo_map[sibling.library_instance_id], sibling.pulp_id] }]
        end

        def build_override_config(destination_repo, incremental_update: false,
                                                    solve_dependencies: false,
                                                    filters: [])
          config = {}
          if incremental_update ||
              (filters.present? && solve_dependencies)
            if Setting[:dependency_solving_algorithm] == 'greedy'
              config[:recursive] = true
            else
              config[:recursive_conservative] = true
            end
            config[:additional_repos] = generate_mapping(destination_repo)
          end
          config
        end

        def import_distribution_data
          distribution = smart_proxy.pulp_api.extensions.repository.distributions(repo.pulp_id).first
          if distribution
            repo.update!(
              :distribution_version => distribution["version"],
              :distribution_arch => distribution["arch"],
              :distribution_family => distribution["family"],
              :distribution_variant => distribution["variant"],
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
                                                "id" => { "$in" => errata_to_delete.map(&:errata_id).sort })
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

        def copy_module_contents(destination_repo, filters:, solve_dependencies:)
          override_config = build_override_config(destination_repo,
                                                  filters: filters,
                                                  solve_dependencies: solve_dependencies)

          filters = filters.module_stream.or(filters.errata) if filters

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
            clause_gen = ::Katello::Util::ModuleStreamClauseGenerator.new(repo, filters)
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
      end
    end
  end
end
