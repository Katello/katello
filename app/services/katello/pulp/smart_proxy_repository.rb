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

      def repos_available_to_capsule(environments = nil, content_view = nil)
        environments = @smart_proxy.lifecycle_environments if environments.nil?
        yum_repos = Katello::Repository.in_environment(environments)
        yum_repos = yum_repos.in_content_views([content_view]) if content_view
        yum_repos = yum_repos.find_all { |repo| repo.node_syncable? }

        puppet_environments = Katello::ContentViewPuppetEnvironment.in_environment(environments)
        puppet_environments = puppet_environments.in_content_view(content_view) if content_view
        yum_repos + puppet_environments
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        @current_repositories ||= @smart_proxy.pulp_repositories
        katello_repo_ids = []
        puppet_repo_ids = []

        @current_repositories.each do |repo|
          found_repo = Katello::Repository.where(:pulp_id => repo[:id]).first
          if found_repo
            katello_repo_ids << found_repo.id
          else
            found_puppet = Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo[:id]).first
            puppet_repo_ids << found_puppet.id if found_puppet
          end
        end

        katello_repos = Katello::Repository.where(:id => katello_repo_ids)
        puppet_repos = Katello::ContentViewPuppetEnvironment.where(:id => puppet_repo_ids)

        if environment_id
          katello_repos = katello_repos.where(:environment_id => environment_id)
          puppet_repos = puppet_repos.where(:environment_id => environment_id)
        end

        if content_view_id
          katello_repos = katello_repos.in_content_views([content_view_id])
          puppet_repos = puppet_repos.in_content_view(content_view_id)
        end

        katello_repos + puppet_repos
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
        @smart_proxy.pulp_repositories.map { |x| x["id"] } - current_repositories.map { |x| x.pulp_id }
      end

      def delete_orphaned_repos
        orphaned_repos.each { |repo| self.smart_proxy.pulp_api.extensions.repository.delete(repo) }
      end
    end
  end
end
