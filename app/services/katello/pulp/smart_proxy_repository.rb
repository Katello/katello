module Katello
  module Pulp
    class SmartProxyRepository
      attr_accessor :smart_proxy

      def initialize(smart_proxy)
        @smart_proxy = smart_proxy
      end

      def ==(other)
        other.class == self.class && other.smart_proxy == smart_proxy
      end

      def default_capsule?
        @smart_proxy.pulp_primary?
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        yum_repos = current_yum_repos(environment_id, content_view_id) || []
        yum_repos
      end

      def current_yum_repos(environment_id = nil, content_view_id = nil)
        katello_repos = Katello::Repository.all
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id

        pulp2_repos = self.smart_proxy.pulp_api.extensions.repository.search_by_repository_ids(katello_repos.pluck(:pulp_id))
        pulp_repo_ids = pulp2_repos.map { |pulp_repo| pulp_repo['id'] }

        katello_repos.where(:pulp_id => pulp_repo_ids)
      end

      def orphaned_repos
        @smart_proxy.pulp_repositories.map { |x| x["id"] } - repos_available_to_capsule.map { |x| x.pulp_id }
      end

      def repos_available_to_capsule
        yum_repos_available_to_capsule
      end

      def yum_repos_available_to_capsule
        yum_repos = Katello::Repository.in_environment(@smart_proxy.lifecycle_environments)
        yum_repos.find_all { |repo| repo.node_syncable? }
      end

      def delete_orphaned_repos
        orphaned_repos.map { |repo| self.smart_proxy.pulp_api.extensions.repository.delete(repo) }.compact
      end
    end
  end
end
