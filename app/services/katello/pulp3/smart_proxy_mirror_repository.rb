module Katello
  module Pulp3
    class SmartProxyMirrorRepository < SmartProxyRepository
      def initialize(smart_proxy)
        fail "Cannot use a central pulp smart proxy" if smart_proxy.pulp_master?
        @smart_proxy = smart_proxy
      end

      def orphaned_repositories
        smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
        katello_pulp_ids = smart_proxy_helper.repos_available_to_capsule.map(&:pulp_id)
        repos_on_capsule = ::Katello::Pulp3::Api::Core.new(smart_proxy).list_all
        repos_on_capsule.reject { |capsule_repo| katello_pulp_ids.include? capsule_repo.name }
      end

      def orphan_repository_versions
        version_hrefs = core_api.repository_versions
        version_hrefs - ::Katello::Repository.where(version_href: version_hrefs).pluck(:version_href)
      end

      def delete_orphan_repositories
        orphaned_repositories.map do |repo|
          ::Katello::Pulp3::Api::Core.new(smart_proxy).repositories_api.delete(repo.pulp_href)
        end
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
