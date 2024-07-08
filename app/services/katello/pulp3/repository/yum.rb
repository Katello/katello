require 'pulp_rpm_client'

module Katello
  module Pulp3
    class Repository
      # rubocop:disable Metrics/ClassLength
      class Yum < ::Katello::Pulp3::Repository
        include Katello::Util::Errata
        include Katello::Util::PulpcoreContentFilters

        UNIT_LIMIT = 10_000

        def remote_options
          options = common_remote_options
          uri = root.url ? URI(root.url) : nil
          unless root.upstream_authentication_token.blank?
            options.merge!(sles_auth_token: root.upstream_authentication_token)
          end
          options.merge!(url: uri.to_s) if uri
          options.merge!(policy: root.download_policy)
        end

        def publication_options(repository_version)
          options = super(repository_version)
          options.merge(checksum_type: root.checksum_type)
        end

        def specific_create_options
          { retain_package_versions: retain_package_versions_count }
        end

        def skip_types
          skip_types = []
          if root.ignorable_content.try(:include?, "srpm")
            skip_types << "srpm"
          end
          if root.ignorable_content.try(:include?, "treeinfo")
            skip_types << "treeinfo"
          end
          skip_types
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{generate_backend_object_name}"
          }
        end

        def import_distribution_data
          distribution = ::Katello::Pulp3::Distribution.fetch_content_list(repository_version: repo.version_href)
          if distribution.results.present?
            repo.update!(
              :distribution_version => distribution.results.first.release_version,
              :distribution_arch => distribution.results.first.arch,
              :distribution_family => distribution.results.first.release_name,
              :distribution_bootable => self.class.distribution_bootable?(distribution)
            )
            if !distribution.results.first.variants.empty? && !distribution.results.first.variants.first.name.nil?
              repo.update!(:distribution_variant => distribution.results.first.variants.map(&:name).join(','))
            end
          end
        end

        def sync_url_params(sync_options)
          params = super
          params.delete(:mirror)
          params[:sync_policy] = repo.mirroring_policy
          params[:optimize] = sync_options[:optimize] if sync_options.key?(:optimize)
          params
        end

        def self.distribution_bootable?(distribution)
          file_paths = distribution.results.first.images.map(&:path)
          file_paths.any? do |path|
            path.include?('vmlinuz') || path.include?('pxeboot') || path.include?('kernel.img') || path.include?('initrd.img') || path.include?('boot.iso')
          end
        end

        def partial_repo_path
          "/pulp/content/#{repo.relative_path}/".sub('//', '/')
        end

        # rubocop:disable Metrics/MethodLength
        def multi_copy_units(repo_id_map, dependency_solving)
          tasks = []

          if repo_id_map.values.pluck(:content_unit_hrefs).flatten.any?
            data = PulpRpmClient::Copy.new
            data.dependency_solving = dependency_solving
            data.config = []
            repo_id_map.each do |source_repo_ids, dest_repo_id_map|
              dest_repo = ::Katello::Repository.find(dest_repo_id_map[:dest_repo])
              dest_repo_href = ::Katello::Pulp3::Repository::Yum.new(dest_repo, SmartProxy.pulp_primary).repository_reference.repository_href
              content_unit_hrefs = dest_repo_id_map[:content_unit_hrefs]
              # Not needed during incremental update due to dest_base_version
              # -> Unless incrementally updating a CV repo that is a soft copy of its library instance.
              # -> I.e. no filters and not an incremental version.
              unless dest_repo_id_map[:base_version]
                source_repo_for_content = ::Katello::Repository.find(source_repo_ids.first)
                unless source_repo_for_content.library_instance?
                  source_repo_for_content = source_repo_for_content.library_instance
                end
                modulemd_defaults_hrefs = modulemd_defaults({ :repository_version => source_repo_for_content.version_href }).map(&:pulp_href).sort
                package_env_hrefs = packageenvironments({ :repository_version => source_repo_for_content.version_href }).map(&:pulp_href).sort
                # Don't perform extra content actions if the repo is a soft copy of its library instance.
                # Taken care of by the IncrementalUpdate action.
                unless dest_repo.soft_copy_of_library?
                  tasks << remove_all_content_from_repo(dest_repo_href)
                  tasks << add_content_for_repo(dest_repo_href, package_env_hrefs) unless package_env_hrefs.empty?
                  tasks << add_content_for_repo(dest_repo_href, modulemd_defaults_hrefs) unless modulemd_defaults_hrefs.empty?
                end
              end
              source_repo_ids.each do |source_repo_id|
                source_repo_version = ::Katello::Repository.find(source_repo_id).version_href
                config = { source_repo_version: source_repo_version, dest_repo: dest_repo_href, content: content_unit_hrefs }
                config[:dest_base_version] = dest_repo_id_map[:base_version] if dest_repo_id_map[:base_version]
                data.config << config
              end
            end
            tasks << copy_content_chunked(data)
          else
            tasks << remove_all_content_from_mapping(repo_id_map)
          end
          tasks.flatten
        end
        # rubocop:enable Metrics/MethodLength

        def copy_api_data_dup(data)
          data_dup = PulpRpmClient::Copy.new
          data_dup.dependency_solving = data.dependency_solving
          data_dup.config = []
          data.config.each do |repo_config|
            config_hash = {
              source_repo_version: repo_config[:source_repo_version],
              dest_repo: repo_config[:dest_repo],
              content: []
            }
            config_hash[:dest_base_version] = repo_config[:dest_base_version] if repo_config[:dest_base_version]
            data_dup.config << config_hash
          end
          data_dup
        end

        def copy_content_chunked(data)
          tasks = []
          # Don't chunk if there aren't enough content units
          if data.config.sum { |repo_config| repo_config[:content].size } <= UNIT_LIMIT
            return api.copy_api.copy_content(data)
          end

          unit_copy_counter = 0
          i = 0
          leftover_units = data.config.first[:content].deep_dup

          # Copy data and clear its content fields
          data_dup = copy_api_data_dup(data)

          while i < data_dup.config.size
            # Copy all units within repo or only some?
            if leftover_units.length < UNIT_LIMIT - unit_copy_counter
              copy_amount = leftover_units.length
            else
              copy_amount = UNIT_LIMIT - unit_copy_counter
            end

            data_dup.config[i][:content] = leftover_units.pop(copy_amount)
            unit_copy_counter += copy_amount
            if unit_copy_counter != 0
              tasks << api.copy_api.copy_content(data_dup)
              unit_copy_counter = 0
            end

            if leftover_units.empty?
              # Nothing more to copy -- clear current config's content
              data_dup.config[i][:content] = []
              i += 1
              # Fetch unit list for next data config
              leftover_units = data.config[i][:content].deep_dup unless i == data_dup.config.size
            end
          end

          tasks
        end

        def remove_all_content_from_mapping(repo_id_map)
          tasks = []
          repo_id_map.each do |_source_repo_ids, dest_repo_id_map|
            dest_repo = ::Katello::Repository.find(dest_repo_id_map[:dest_repo])
            dest_repo_href = ::Katello::Pulp3::Repository::Yum.new(dest_repo, SmartProxy.pulp_primary).repository_reference.repository_href
            tasks << remove_all_content_from_repo(dest_repo_href)
          end
          tasks
        end

        def copy_units(source_repository, content_unit_hrefs, remove_all)
          remove_all = true if remove_all.nil?
          tasks = []

          if content_unit_hrefs.sort!.any?
            content_unit_hrefs += packageenvironments({ :repository_version => source_repository.version_href }).map(&:pulp_href).sort
            content_unit_hrefs += modulemd_defaults({ :repository_version => source_repository.version_href }).map(&:pulp_href).sort
            first_slice = remove_all
            content_unit_hrefs.each_slice(UNIT_LIMIT) do |slice|
              tasks << add_content(slice, first_slice)
              first_slice = false
            end
          # If we're merging composite cv repositories, don't clear out the Pulp repository.
          elsif remove_all
            tasks << remove_all_content
          end
          tasks
        end

        def remove_all_content_from_repo(repo_href)
          data = PulpRpmClient::RepositoryAddRemoveContent.new(
            remove_content_units: ['*'])
          api.repositories_api.modify(repo_href, data)
        end

        def remove_all_content
          data = PulpRpmClient::RepositoryAddRemoveContent.new(
            remove_content_units: ['*'])
          api.repositories_api.modify(repository_reference.repository_href, data)
        end

        def packageenvironments(options = {})
          Katello::Pulp3::Api::Core.fetch_from_list { |page_opts| api.content_package_environments_api.list(page_opts.merge(options)) }
        end

        def modulemd_defaults(options = {})
          Katello::Pulp3::Api::Core.fetch_from_list { |page_opts| api.content_modulemd_defaults_api.list(page_opts.merge(options)) }
        end

        def metadatafiles(options = {})
          api.content_repo_metadata_files_api.list(options)
        end

        def distributiontrees(options = {})
          api.content_distribution_trees_api.list(options)
        end

        def add_filter_content(source_repo_ids, filters, filter_list_map, additional_included_errata)
          filters.each do |filter|
            if filter.inclusion
              source_repo_ids.each do |repo_id|
                filter_list_map[:whitelist_ids] += filter.content_unit_pulp_ids(::Katello::Repository.find(repo_id))
              end
            elsif filter.class == ContentViewErratumFilter
              source_repo_ids.each do |repo_id|
                filter_list_map[:blacklist_ids] += filter.content_unit_pulp_ids(::Katello::Repository.find(repo_id), additional_included_errata)
              end
            else
              source_repo_ids.each do |repo_id|
                filter_list_map[:blacklist_ids] += filter.content_unit_pulp_ids(::Katello::Repository.find(repo_id))
              end
            end
          end
          filter_list_map
        end

        def add_un_modular_rpms(source_repo_ids, filters, filter_list_map)
          if (filter_list_map[:whitelist_ids].empty? && filters.select { |filter| filter.inclusion }.empty?)
            filter_list_map[:whitelist_ids] += source_repo_ids.collect do |source_repo_id|
              source_repo = ::Katello::Repository.find(source_repo_id)
              source_repo.rpms.where(:modular => false).pluck(:pulp_id).sort
            end
          end
          filter_list_map
        end

        def add_modular_content(source_repo_ids, filters, modular_filters, filter_list_map)
          inclusion_modular_filters = modular_filters.select { |filter| filter.inclusion }
          exclusion_modular_filters = modular_filters - inclusion_modular_filters
          if inclusion_modular_filters.empty? &&
              !(filters.any? { |filter| filter.class == ContentViewErratumFilter && filter.inclusion })
            source_repo_ids.each do |source_repo_id|
              source_repo = ::Katello::Repository.find(source_repo_id)
              filter_list_map[:whitelist_ids] += source_repo.rpms.where(:modular => true).pluck(:pulp_id).sort
              filter_list_map[:whitelist_ids] += source_repo.module_streams.pluck(:pulp_id).sort
            end
          end

          unless inclusion_modular_filters.empty?
            filter_list_map[:whitelist_ids] += source_repo_ids.collect do |source_repo_id|
              source_repo = ::Katello::Repository.find(source_repo_id)
              modular_packages(source_repo, inclusion_modular_filters)
            end
          end

          unless exclusion_modular_filters.empty?
            filter_list_map[:blacklist_ids] += source_repo_ids.collect do |source_repo_id|
              source_repo = ::Katello::Repository.find(source_repo_id)
              modular_packages(source_repo, exclusion_modular_filters)
            end
          end

          filter_list_map
        end

        # rubocop:disable Metrics/MethodLength
        def copy_content_from_mapping(repo_id_map, options = {})
          repo_id_map.each do |source_repo_ids, dest_repo_map|
            filters = [ContentViewErratumFilter, ContentViewPackageGroupFilter, ContentViewPackageFilter].collect do |filter_class|
              filter_class.where(:id => dest_repo_map[:filter_ids])
            end
            modular_filters = ContentViewModuleStreamFilter.where(:id => dest_repo_map[:filter_ids])
            filters.flatten!.compact!

            errata_filters = ContentViewErratumFilter.where(:id => dest_repo_map[:filter_ids])

            # Only filter out RPMs & modules via an erratum filter if they're not included in other allowed errata.
            # Begin this by calculating all the errata that should be copied.
            # If there are exclude filters, send the errata to the relevant methods to ensure their contents aren't excluded.
            additional_included_errata = []
            all_excluded_errata = []
            unless errata_filters.blacklist.empty?
              all_included_errata, all_excluded_errata = filtered_errata(errata_filters, source_repo_ids)
              additional_included_errata = all_included_errata - all_excluded_errata
            end

            filter_list_map = { whitelist_ids: [], blacklist_ids: [] }
            filter_list_map = add_filter_content(source_repo_ids, filters, filter_list_map, additional_included_errata)
            filter_list_map = add_un_modular_rpms(source_repo_ids, filters, filter_list_map)
            filter_list_map = add_modular_content(source_repo_ids, filters, modular_filters, filter_list_map)

            whitelist_ids = filter_list_map[:whitelist_ids].flatten&.uniq
            blacklist_ids = filter_list_map[:blacklist_ids].flatten&.uniq
            content_unit_hrefs = whitelist_ids - blacklist_ids

            source_repo_ids.each do |source_repo_id|
              content_unit_hrefs += ::Katello::Repository.find(source_repo_id).srpms.pluck(:pulp_id)
            end

            if content_unit_hrefs.any?
              source_repo_ids.each do |source_repo_id|
                content_unit_hrefs += additional_content_hrefs(::Katello::Repository.find(source_repo_id), content_unit_hrefs, all_excluded_errata)
              end
            end

            dest_repo_map[:content_unit_hrefs] = content_unit_hrefs.uniq.sort
          end

          dependency_solving = options[:solve_dependencies] || false

          multi_copy_units(repo_id_map, dependency_solving)
        end
        # rubocop:enable Metrics/MethodLength

        # Calculate errata that should be included and excluded.
        # https://projects.theforeman.org/issues/34437
        def filtered_errata(errata_filters, source_repository_ids)
          if errata_filters.whitelist.empty?
            all_included_errata = ::Katello::Erratum.joins("inner join katello_repository_errata on katello_errata.id = katello_repository_errata.erratum_id").
              joins("inner join katello_repositories on katello_repositories.id = katello_repository_errata.repository_id").
              where("katello_repositories.id in (?)", source_repository_ids)
          else
            all_included_errata = errata_filters.whitelist.collect do |filter|
              ::Katello::Erratum.joins("inner join katello_repository_errata on katello_errata.id = katello_repository_errata.erratum_id").
                where(filter.generate_clauses(nil)).where("katello_repository_errata.repository_id in (?)", source_repository_ids)
            end
            all_included_errata.flatten!
          end
          all_excluded_errata = errata_filters.blacklist.collect do |filter|
            ::Katello::Erratum.joins("inner join katello_repository_errata on katello_errata.id = katello_repository_errata.erratum_id").
              where(filter.generate_clauses(nil)).where("katello_repository_errata.repository_id in (?)", source_repository_ids)
          end
          all_excluded_errata.flatten!
          return all_included_errata, all_excluded_errata
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
        def copy_content_for_source(source_repository, options = {})
          package_filters = [ContentViewPackageGroupFilter, ContentViewPackageFilter].collect do |filter_class|
            filter_class.where(:id => options[:filter_ids])
          end
          package_filters.flatten!.compact!

          errata_filters = ContentViewErratumFilter.where(:id => options[:filter_ids])

          whitelist_ids = []
          blacklist_ids = []

          # Only filter out RPMs & modules via an erratum filter if they're not included in other allowed errata.
          # Begin this by calculating all the errata that should be copied.
          # If there are exclude filters, send the errata to the relevant methods to ensure their contents aren't excluded.
          additional_included_errata = []
          all_excluded_errata = []
          unless errata_filters.blacklist.empty?
            all_included_errata, all_excluded_errata = filtered_errata(errata_filters, [source_repository.id])
            additional_included_errata = all_included_errata - all_excluded_errata
          end

          (errata_filters + package_filters).each do |filter|
            if filter.inclusion
              whitelist_ids += filter.content_unit_pulp_ids(source_repository)
            elsif filter.class == ContentViewErratumFilter
              blacklist_ids += filter.content_unit_pulp_ids(source_repository, additional_included_errata)
            else
              blacklist_ids += filter.content_unit_pulp_ids(source_repository)
            end
          end

          whitelist_ids = source_repository.rpms.where(:modular => false).pluck(:pulp_id).sort if (whitelist_ids.empty? && (errata_filters + package_filters).select { |filter| filter.inclusion }.empty?)

          modular_filters = ContentViewModuleStreamFilter.where(:id => options[:filter_ids])
          inclusion_modular_filters = modular_filters.select { |filter| filter.inclusion }
          exclusion_modular_filters = modular_filters - inclusion_modular_filters
          if inclusion_modular_filters.empty? && errata_filters.whitelist.empty?
            whitelist_ids += source_repository.rpms.where(:modular => true).pluck(:pulp_id).sort
            whitelist_ids += source_repository.module_streams.pluck(:pulp_id).sort
          end
          whitelist_ids += modular_packages(source_repository, inclusion_modular_filters) unless inclusion_modular_filters.empty?
          blacklist_ids += modular_packages(source_repository, exclusion_modular_filters) unless exclusion_modular_filters.empty?
          content_unit_hrefs = whitelist_ids - blacklist_ids
          content_unit_hrefs += source_repository.srpms.pluck(:pulp_id)
          if content_unit_hrefs.any?
            content_unit_hrefs += additional_content_hrefs(source_repository, content_unit_hrefs, all_excluded_errata)
          end
          copy_units(source_repository, content_unit_hrefs.uniq, options[:remove_all])
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity

        def modular_packages(source_repository, filters)
          list_ids = []
          filters.each do |filter|
            list_ids += filter.content_unit_pulp_ids(source_repository, true)
          end
          list_ids
        end

        def additional_content_hrefs(source_repository, content_unit_hrefs, all_excluded_errata)
          repo_service = source_repository.backend_service(SmartProxy.pulp_primary)
          options = { :repository_version => source_repository.version_href }

          errata_to_include = filter_errata_by_pulp_href(source_repository.errata, content_unit_hrefs,
                                                         source_repository.rpms.pluck(:filename) +
                                                         source_repository.srpms.pluck(:filename),
                                                         source_repository.module_streams.map(&:module_spec)) -
                                                         all_excluded_errata
          content_unit_hrefs += errata_to_include.collect do |erratum|
            erratum.repository_errata.where(repository_id: source_repository.id).pluck(:erratum_pulp3_href)
          end
          content_unit_hrefs.flatten!

          package_groups_to_include = filter_package_groups_by_pulp_href(source_repository.package_groups, content_unit_hrefs)
          content_unit_hrefs += package_groups_to_include.pluck(:pulp_id)

          metadata_file_hrefs_to_include = filter_metadatafiles_by_pulp_hrefs(
            repo_service.metadatafiles(options)&.results, content_unit_hrefs)
          content_unit_hrefs += metadata_file_hrefs_to_include

          distribution_tree_hrefs_to_include = filter_distribution_trees_by_pulp_hrefs(
            repo_service.distributiontrees(options)&.results, content_unit_hrefs)
          content_unit_hrefs + distribution_tree_hrefs_to_include
        end
      end
    end
  end
end
