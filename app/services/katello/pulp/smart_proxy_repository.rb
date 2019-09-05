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
        @smart_proxy.pulp_master?
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        yum_repos = current_yum_repos(environment_id, content_view_id) || []
        puppet_envs = current_puppet_environments(environment_id, content_view_id) || []
        yum_repos + puppet_envs
      end

      def current_yum_repos(environment_id = nil, content_view_id = nil)
        katello_repos = Katello::Repository.all
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id

        pulp2_repos = self.smart_proxy.pulp_api.extensions.repository.search_by_repository_ids(katello_repos.pluck(:pulp_id))
        pulp_repo_ids = pulp2_repos.map { |pulp_repo| pulp_repo['id'] }

        katello_repos.where(:pulp_id => pulp_repo_ids)
      end

      def current_puppet_environments(environment_id = nil, content_view_id = nil)
        puppet_repos = Katello::ContentViewPuppetEnvironment.all
        puppet_repos = puppet_repos.where(:environment_id => environment_id) if environment_id
        puppet_repos = puppet_repos.in_content_view(content_view_id) if content_view_id

        pulp_repos = self.smart_proxy.pulp_api.extensions.repository.search_by_repository_ids(puppet_repos.pluck(:pulp_id))

        puppet_repos.where(:pulp_id => pulp_repos.map { |pulp_repo| pulp_repo['id'] })
      end

      def current_repositories_data(environment = nil, content_view = nil)
        @pulp_repositories ||= smart_proxy.pulp_repositories

        repos = Katello::Repository
        repos = repos.in_environment(environment) if environment
        repos = repos.in_content_views([content_view]) if content_view
        puppet_envs = Katello::ContentViewPuppetEnvironment
        puppet_envs = puppet_envs.in_environment(environment) if environment
        puppet_envs = puppet_envs.in_content_view(content_view) if content_view

        repo_ids = repos.pluck(:pulp_id) + puppet_envs.pluck(:pulp_id)

        @pulp_repositories.select { |r| repo_ids.include?(r['id']) }
      end

      def orphaned_repos
        @smart_proxy.pulp_repositories.map { |x| x["id"] } - repos_available_to_capsule.map { |x| x.pulp_id }
      end

      def delete_orphaned_repos
        orphaned_repos.map { |repo| self.smart_proxy.pulp_api.extensions.repository.delete(repo) }.compact
      end
    end
  end
end
