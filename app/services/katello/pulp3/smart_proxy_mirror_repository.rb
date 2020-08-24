module Katello
  module Pulp3
    class SmartProxyMirrorRepository < SmartProxyRepository
      def initialize(smart_proxy)
        fail "Cannot use a central pulp smart proxy" if smart_proxy.pulp_master?
        @smart_proxy = smart_proxy
      end

      def orphaned_repositories
        repo_map = {}

        smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
        katello_pulp_ids = smart_proxy_helper.combined_repos_available_to_capsule.map(&:pulp_id)
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_service_class.api(smart_proxy)
          repo_map[api] = api.list_all.reject { |capsule_repo| katello_pulp_ids.include? capsule_repo.name }
        end

        repo_map
      end

      def orphan_repository_versions
        repo_version_map = {}

        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_service_class.api(smart_proxy)
          version_hrefs = api.repository_versions
          orphan_version_hrefs = api.list_all.collect do |pulp_repo|
            mirror_repo_versions = api.versions_list_for_repository(pulp_repo.pulp_href, ordering: :_created)
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
          pulp3_class = repo_type.pulp3_service_class
          orphan_distributions(pulp3_class).each do |distribution|
            tasks << pulp3_class.api(smart_proxy).delete_distribution(distribution.pulp_href)
          end
        end
        tasks
      end

      def orphan_distributions(pulp3_service_class)
        api = pulp3_service_class.api(smart_proxy)
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

      def delete_orphan_remotes
        tasks = []
        repo_names = Katello::Repository.pluck(:pulp_id)
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_service_class.api(smart_proxy)
          remotes = api.remotes_list

          remotes.each do |remote|
            tasks << api.delete_remote(remote.pulp_href) unless repo_names.include?(remote.name)
          end
        end
        tasks
      end
    end
  end
end
