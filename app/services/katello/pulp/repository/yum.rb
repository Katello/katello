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
          tasks = []
          tasks.concat(copy_filterable_content(destination_repo, ::Katello::Pulp::Rpm::CONTENT_TYPE, options))
          tasks.concat(copy_filterable_content(destination_repo, ::Katello::Pulp::Erratum::CONTENT_TYPE, options))
          tasks.concat(copy_modular_content(destination_repo, options))

          [:srpm, :package_group, :yum_repo_metadata_file, :distribution, :module, :module_default].each do |type|
            tasks << smart_proxy.pulp_api.extensions.send(type).copy(repo.pulp_id, destination_repo.pulp_id)
          end
          tasks
        end

        def copy_modular_content(destination_repo, options)
          tasks = []
          # always copy modular rpms
          tasks.concat(copy_filterable_content(destination_repo, ::Katello::Pulp::Rpm::CONTENT_TYPE,
                                    options.merge(rpm_filenames: repo.rpms.modular.pluck(:filename))))

          # copy over the modular errata
          tasks.concat(copy_filterable_content(destination_repo, ::Katello::Pulp::Erratum::CONTENT_TYPE,
                                    options.merge(errata_ids: repo.errata.modular.pluck(:errata_id))))

          [:module, :module_default].each do |type|
            tasks << smart_proxy.pulp_api.extensions.send(type).copy(repo.pulp_id, destination_repo.pulp_id)
          end
          tasks
        end

        def copy_filterable_content(destination_repo, content_type, options)
          override_config = Katello::Repository.build_override_config(options)
          copy_clauses, remove_clauses = generate_copy_clauses(options[:filters], content_type, options)

          unit = :rpm
          if content_type == ::Katello::Pulp::Erratum::CONTENT_TYPE
            unit = :errata
          end

          tasks = [smart_proxy.pulp_api.extensions.send(unit).copy(repo.pulp_id, destination_repo.pulp_id,
                   copy_clauses.merge(:override_config => override_config))]

          if remove_clauses
            tasks << smart_proxy.pulp_api.extensions.repository.unassociate_units(destination_repo.pulp_id,
                                                                         type_ids: [content_type],
                                                                         filters: {unit: remove_clauses})
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
          [purge_empty_errata, purge_empty_package_groups]
        end

        def should_purge_empty_contents?
          true
        end

        private

        def purge_empty_errata
          task = nil
          repo.empty_errata! do |errata_to_delete|
            task = repo.unassociate_by_filter(::Katello::ContentViewErratumFilter::CONTENT_TYPE,
                                                "id" => { "$in" => errata_to_delete.map(&:errata_id) })
          end
          task
        end

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

        def generate_copy_clauses(filters, content_type, options = {})
          if options[:rpm_filenames]&.any?
            copy_clauses = {filters: {unit: { 'filename' => { '$in' => options[:rpm_filenames] } }}}
            remove_clauses = nil
          elsif options[:errata_ids]&.any?
            copy_clauses = {filters: {unit: { 'id' => { '$in' => options[:errata_ids]} }}}
            remove_clauses = nil
          elsif filters
            if content_type == ::Katello::Pulp::Rpm::CONTENT_TYPE
              clause_generator_class = ::Katello::Util::PackageClauseGenerator
            else
              clause_generator_class = ::Katello::Util::ErratumClauseGenerator
            end

            clause_gen = clause_generator_class.new(repo, filters.yum)
            clause_gen.generate

            copy = clause_gen.copy_clause
            copy_clauses = {filters: {unit: copy }} if copy

            remove = clause_gen.remove_clause
            remove_clauses = {filters: {unit: remove}} if remove
          else
            copy_clauses = {}
            remove_clauses = nil
          end
          if content_type == ::Katello::Pulp::Rpm::CONTENT_TYPE
            copy_clauses.merge!(fields: ::Katello::Pulp::Rpm::PULP_SELECT_FIELDS)
          else
            copy_clauses.merge!(fields: ::Katello::Pulp::Erratum::PULP_SELECT_FIELDS)
          end
          [copy_clauses, remove_clauses]
        end
      end
    end
  end
end
