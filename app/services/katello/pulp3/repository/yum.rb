require 'pulp_rpm_client'

module Katello
  module Pulp3
    class Repository
      class Yum < ::Katello::Pulp3::Repository
        include Katello::Util::Errata
        include Katello::Util::PulpcoreContentFilters

        def remote_options
          if root.url.blank?
            common_remote_options.merge(url: nil, policy: root.download_policy)
          else
            common_remote_options.merge(policy: root.download_policy)
          end
        end

        def skip_types
          skip_types = []
          if root.ignorable_content.try(:include?, "srpm")
            skip_types << "srpm"
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

        def sync_params
          {remote: repo.remote_href, mirror: repo.root.mirror_on_sync, optimize: false}
        end

        def mirror_remote_options
          policy = smart_proxy.download_policy

          if smart_proxy.download_policy == SmartProxy::DOWNLOAD_INHERIT
            policy = repo.root.download_policy
          end

          { policy: policy }
        end

        def import_distribution_data
          distribution = ::Katello::Pulp3::Distribution.fetch_content_list(repository_version: repo.version_href)
          if distribution.results.present?
            repo.update!(
              :distribution_version => distribution.results.first.release_version,
              :distribution_arch => distribution.results.first.arch,
              :distribution_family => distribution.results.first.release_name,
              :distribution_uuid => distribution.results.first.pulp_href,
              :distribution_bootable => self.class.distribution_bootable?(distribution)
            )
            unless distribution.results.first.variants.empty?
              unless distribution.results.first.variants.first.name.nil?
                repo.update!(:distribution_variant => distribution.results.first.variants.first.name)
              end
            end
          end
        end

        def self.distribution_bootable?(distribution)
          file_paths = distribution.results.first.images.map(&:path)
          file_paths.any? do |path|
            path.include?('vmlinuz') || path.include?('pxeboot') || path.include?('kernel.img') || path.include?('initrd.img') || path.include?('boot.iso')
          end
        end

        def partial_repo_path
          "/pulp/repos/#{repo.relative_path}/".sub('//', '/')
        end

        def multi_copy_units(repo_id_map, content_unit_hrefs, dependency_solving)
          tasks = []

          content_unit_hrefs.sort!
          if content_unit_hrefs.any?
            data = PulpRpmClient::Copy.new
            data.dependency_solving = dependency_solving
            data.config = []
            repo_id_map.each do |source_repo_ids, dest_repo_id_map|
              dest_repo = ::Katello::Repository.find(dest_repo_id_map[:dest_repo])
              dest_repo_href = ::Katello::Pulp3::Repository::Yum.new(dest_repo, SmartProxy.pulp_master).repository_reference.repository_href
              tasks << remove_all_content_from_repo(dest_repo_href)
              source_repo_ids.each do |source_repo_id|
                source_repo_version = ::Katello::Repository.find(source_repo_id).version_href
                config = {
                  source_repo_version: source_repo_version,
                  dest_repo: dest_repo_href,
                  content: content_unit_hrefs
                }
                config[:dest_base_version] = dest_repo_id_map[:base_version] if dest_repo_id_map[:base_version]
                data.config << config
              end
            end
            tasks << api.copy_api.copy_content(data)
          end
          tasks
        end

        def copy_units(source_repository, content_unit_hrefs, dependency_solving, dest_base_version = nil,
                       additional_repo_map = {})
          tasks = []
          if content_unit_hrefs.sort!.any?
            data = PulpRpmClient::Copy.new
            data.config = [{
              source_repo_version: source_repository.version_href,
              dest_repo: repository_reference.repository_href,
              content: content_unit_hrefs
            }]
            data.config[:dest_base_version] = dest_base_version if dest_base_version
            data.dependency_solving = dependency_solving
            if dependency_solving
              # repo_map example: {
              #   <source_repo_id>: {
              #     dest_repo: <dest_repo_id>,
              #     base_version: <base_version>
              #   }
              # }
              additional_repo_map.each do |source_repo, dest_repo_map|
                source_repo_version = ::Katello::Repository.find(source_repo).version_href

                dest_repo = ::Katello::Repository.find(dest_repo_map[:dest_repo])
                dest_repo_href = ::Katello::Pulp3::Repository::Yum.new(dest_repo, SmartProxy.pulp_master).repository_reference.repository_href
                additional_config = {
                  source_repo_version: source_repo_version,
                  dest_repo: dest_repo_href,
                  dest_base_version: 0,
                  content: content_unit_hrefs
                }
                additional_config[:dest_base_version] = dest_repo_map[:base_version] if dest_repo_map[:base_version]

                data.config << additional_config
              end
            end
            package_env_hrefs = packageenvironments({ :repository_version => source_repository.version_href }).map(&:pulp_href).sort
            tasks << api.copy_api.copy_content(data)
            tasks << add_content(package_env_hrefs) unless package_env_hrefs.empty?
          else
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

        def metadatafiles(options = {})
          api.content_repo_metadata_files_api.list(options)
        end

        def distributiontrees(options = {})
          api.content_distribution_trees_api.list(options)
        end

        def copy_content_from_mapping(repo_id_map, options = {})
          filters = [ContentViewErratumFilter, ContentViewPackageGroupFilter, ContentViewPackageFilter].collect do |filter_class|
            filter_class.where(:id => options[:filter_ids])
          end

          filters.flatten!.compact!

          whitelist_ids = []
          blacklist_ids = []
          filters.each do |filter|
            repo_id_map.each do |source_repo_ids, dest_repo|
              if filter.inclusion
                source_repo_ids.each do |repo_id|
                  whitelist_ids += filter.content_unit_pulp_ids(::Katello::Repository.find(repo_id))
                end
              else
                source_repo_ids.each do |repo_id|
                  blacklist_ids += filter.content_unit_pulp_ids(::Katello::Repository.find(repo_id))
                end
              end
            end
          end

          # TODO: This part could probably be improved.  Will probably change when module support is in.
          if whitelist_ids.empty? && filters.select { |filter| filter.inclusion }.empty?
            whitelist_ids = repo_id_map.keys.collect do |source_repo_ids|
              source_repo_ids.collect do |source_repo_id|
                source_repo = ::Katello::Repository.find(source_repo_id)
                source_repo.rpms.pluck(:pulp_id).sort
              end
            end
            whitelist_ids.flatten!.uniq!
          end

          content_unit_hrefs = whitelist_ids - blacklist_ids

          if content_unit_hrefs.any?
            repo_id_map.each do |source_repo_ids, dest_repo|
              source_repo_ids.each do |source_repo_id|
                content_unit_hrefs += additional_content_hrefs(::Katello::Repository.find(source_repo_id), content_unit_hrefs)
                content_unit_hrefs += ::Katello::Repository.find(source_repo_id).srpms.pluck(:pulp_id)
              end
            end
          end

          dependency_solving = options[:solve_dependencies] || false

          multi_copy_units(repo_id_map, content_unit_hrefs.uniq, dependency_solving)
        end

        def copy_content_for_source(source_repository, options = {})
          filters = [ContentViewErratumFilter, ContentViewPackageGroupFilter, ContentViewPackageFilter].collect do |filter_class|
            filter_class.where(:id => options[:filter_ids])
          end

          filters.flatten!.compact!

          whitelist_ids = []
          blacklist_ids = []
          filters.each do |filter|
            if filter.inclusion
              whitelist_ids += filter.content_unit_pulp_ids(source_repository)
            else
              blacklist_ids += filter.content_unit_pulp_ids(source_repository)
            end
          end

          whitelist_ids = source_repository.rpms.where(:modular => false).pluck(:pulp_id).sort if (whitelist_ids.empty? && filters.select { |filter| filter.inclusion }.empty?)

          modular_filters = ContentViewModuleStreamFilter.where(:id => options[:filter_ids])
          inclusion_modular_filters = modular_filters.select { |filter| filter.inclusion }
          exclusion_modular_filters = modular_filters - inclusion_modular_filters
          if inclusion_modular_filters.empty? && !(filters.any? { |filter| filter.class == ContentViewErratumFilter && filter.inclusion })
            whitelist_ids += source_repository.rpms.where(:modular => true).pluck(:pulp_id).sort
            whitelist_ids += source_repository.module_streams.pluck(:pulp_id).sort
          end
          whitelist_ids += modular_packages(source_repository, inclusion_modular_filters) unless inclusion_modular_filters.empty?
          blacklist_ids += modular_packages(source_repository, exclusion_modular_filters) unless exclusion_modular_filters.empty?
          content_unit_hrefs = whitelist_ids - blacklist_ids
          if content_unit_hrefs.any?
            content_unit_hrefs += additional_content_hrefs(source_repository, content_unit_hrefs)
          end
          content_unit_hrefs += source_repository.srpms.pluck(:pulp_id)

          dependency_solving = options[:solve_dependencies] || false
          copy_units(source_repository, content_unit_hrefs.uniq, dependency_solving)
        end

        def modular_packages(source_repository, filters)
          list_ids = []
          filters.each do |filter|
            list_ids += filter.content_unit_pulp_ids(source_repository, true)
          end
          list_ids
        end

        def additional_content_hrefs(source_repository, content_unit_hrefs)
          repo_service = source_repository.backend_service(SmartProxy.pulp_master)
          options = { :repository_version => source_repository.version_href }

          errata_to_include = filter_errata_by_pulp_href(source_repository.errata, content_unit_hrefs)
          content_unit_hrefs += errata_to_include.collect { |erratum| erratum.repository_errata.pluck(:erratum_pulp3_href) }.flatten

          package_groups_to_include = filter_package_groups_by_pulp_href(source_repository.package_groups, content_unit_hrefs)
          content_unit_hrefs += package_groups_to_include.pluck(:pulp_id)

          metadata_file_hrefs_to_include = filter_metadatafiles_by_pulp_hrefs(
            repo_service.metadatafiles(options).results, content_unit_hrefs)
          content_unit_hrefs += metadata_file_hrefs_to_include

          distribution_tree_hrefs_to_include = filter_distribution_trees_by_pulp_hrefs(
            repo_service.distributiontrees(options).results, content_unit_hrefs)
          content_unit_hrefs + distribution_tree_hrefs_to_include
        end
      end
    end
  end
end
