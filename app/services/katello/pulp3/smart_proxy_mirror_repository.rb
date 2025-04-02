module Katello
  module Pulp3
    class SmartProxyMirrorRepository < SmartProxyRepository
      def initialize(smart_proxy)
        fail "Cannot use a central pulp smart proxy" if smart_proxy.pulp_primary?
        @smart_proxy = smart_proxy
      end

      def orphaned_repositories
        repo_map = {}

        smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
        katello_pulp_ids = smart_proxy_helper.combined_repos_available_to_capsule.map(&:pulp_id)
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          repo_map[api] = api.list_all.reject { |capsule_repo| katello_pulp_ids.include? capsule_repo.name }
        end

        repo_map
      end

      def orphan_repository_versions
        repo_version_map = {}

        # TODO: if there is an error, check if the related distribution is deletable.
        # If it is (no expected path), then delete the distribution and then the version.
        # If it is not, skip deleting the version and log an error.
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          version_hrefs = api.repository_versions
          orphan_version_hrefs = api.list_all.collect do |pulp_repo|
            mirror_repo_versions = api.versions_list_for_repository(pulp_repo.pulp_href, ordering: ['-pulp_created'])
            version_hrefs = mirror_repo_versions.select { |repo_version| repo_version.number != 0 }.collect { |version| version.pulp_href }

            version_hrefs - [pulp_repo.latest_version_href]
          end
          repo_version_map[api] = orphan_version_hrefs.flatten
        end

        repo_version_map
      end

      def delete_orphan_repositories
        tasks = []

        orphaned_repositories.each do |api, pulp3_repo_list|
          tasks << pulp3_repo_list.collect do |repo|
            api.repositories_api.delete(repo.pulp_href)
          end
        end

        tasks.flatten!
      end

      def delete_orphan_distributions
        tasks = []
        pulp3_enabled_repo_types.each do |repo_type|
          orphan_distributions(repo_type).each do |distribution|
            tasks << repo_type.pulp3_api(smart_proxy).delete_distribution(distribution.pulp_href)
          end
        end
        tasks
      end

      def orphan_distributions(repo_type)
        api = repo_type.pulp3_api(smart_proxy)
        api.distributions_list_all.select do |distribution|
          dist = api.get_distribution(distribution.pulp_href)
          self.class.orphan_distribution?(dist)
        end
      end

      def self.orphan_distribution?(distribution)
        distribution.try(:publication).nil? &&
            distribution.try(:repository).nil? &&
            distribution.try(:repository_version).nil?
      end

      def delete_orphan_alternate_content_sources
        tasks = []
        known_acs_hrefs = []
        known_acss = smart_proxy.smart_proxy_alternate_content_sources
        known_acs_hrefs = known_acss.pluck(:alternate_content_source_href) if known_acss.present?

        if RepositoryTypeManager.enabled_repository_types['file']
          file_acs_api = ::Katello::Pulp3::Repository.api(smart_proxy, 'file').alternate_content_source_api
          orphan_file_acs_hrefs = file_acs_api.list.results.map(&:pulp_href) - known_acs_hrefs
          orphan_file_acs_hrefs.each do |orphan_file_acs_href|
            tasks << file_acs_api.delete(orphan_file_acs_href)
          end
        end
        if RepositoryTypeManager.enabled_repository_types['yum']
          yum_acs_api = ::Katello::Pulp3::Repository.api(smart_proxy, 'yum').alternate_content_source_api
          orphan_yum_acs_hrefs = yum_acs_api.list.results.map(&:pulp_href) - known_acs_hrefs
          orphan_yum_acs_hrefs.each do |orphan_yum_acs_href|
            tasks << yum_acs_api.delete(orphan_yum_acs_href)
          end
        end
      end

      def delete_orphan_remotes
        tasks = []
        smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
        repo_names = smart_proxy_helper.combined_repos_available_to_capsule.map(&:pulp_id)
        acs_remotes = Katello::SmartProxyAlternateContentSource.pluck(:remote_href)
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          remotes = api.remotes_list_all(smart_proxy)

          remotes.each do |remote|
            if !repo_names.include?(remote.name) && !acs_remotes.include?(remote.pulp_href)
              tasks << api.delete_remote(remote.pulp_href)
            end
          end
        end
        tasks
      end
    end
  end
end
