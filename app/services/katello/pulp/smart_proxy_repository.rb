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
        yum_repos = yum_repos_available_to_capsule(environments, content_view) || []
        puppet_envs = puppet_environments_available_to_capsule(environments, content_view) || []
        yum_repos + puppet_envs
      end

      def yum_repos_available_to_capsule(environments = nil, content_view = nil)
        environments = @smart_proxy.lifecycle_environments if environments.nil?
        yum_repos = Katello::Repository.in_environment(environments)
        yum_repos = yum_repos.in_content_views([content_view]) if content_view
        yum_repos.select(&:node_syncable?)
      end

      def puppet_environments_available_to_capsule(environments = nil, content_view = nil)
        environments = @smart_proxy.lifecycle_environments if environments.nil?
        puppet_environments = Katello::ContentViewPuppetEnvironment.in_environment(environments)
        puppet_environments = puppet_environments.in_content_view(content_view) if content_view
        puppet_environments
      end

      def affected_repositories(environment, content_view, repository)
        if repository
          [repository]
        else
          repos_available_to_capsule(environment, content_view)
        end
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
        if smart_proxy.pulp3_enabled?
          pulp3_repos = ::Katello::Pulp3::Repository.new(nil, smart_proxy).list(name_in: katello_repos.pluck(:pulp_id))
          pulp_repo_ids.concat(pulp3_repos.map(&:name))
        end

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
        @smart_proxy.pulp_repositories.map { |x| x["id"] } - current_repositories.map { |x| x.pulp_id }
      end

      def delete_orphaned_repos
        orphaned_repos.map { |repo| self.smart_proxy.pulp_api.extensions.repository.delete(repo) }.compact
      end

      def get_repository_ids(environment, content_view, repository)
        if environment
          repository_ids = repos_available_to_capsule(environment, content_view).map(&:pulp_id)
        elsif repository
          repository_ids = [repository.pulp_id]
          environment = repository.environment
        else
          repository_ids = repos_available_to_capsule.map(&:pulp_id)
        end

        if environment && !self.smart_proxy.lifecycle_environments.include?(environment)
          fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
        end

        repository_ids
      end
    end
  end
end
