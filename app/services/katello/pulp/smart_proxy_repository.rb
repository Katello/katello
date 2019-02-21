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
        yum_repos.find_all { |repo| repo.node_syncable? }
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

      def repos_needing_updates(environment, content_view, repository)
        repos = affected_repositories(environment, content_view, repository)
        need_importer_update = needs_importer_updates(repos)
        need_distributor_update = needs_distributor_updates(repos)
        (need_distributor_update + need_importer_update).uniq
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        yum_repos = current_yum_repos(environment_id, content_view_id) || []
        puppet_envs = current_puppet_environments(environment_id, content_view_id) || []
        yum_repos + puppet_envs
      end

      def current_yum_repos(environment_id = nil, content_view_id = nil)
        @current_repositories ||= @smart_proxy.pulp_repositories
        katello_repo_ids = []

        @current_repositories.each do |repo|
          found_repo = Katello::Repository.where(:pulp_id => repo[:id]).first
          katello_repo_ids << found_repo.id if found_repo
        end
        katello_repos = Katello::Repository.where(:id => katello_repo_ids)
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id
        katello_repos
      end

      def current_puppet_environments(environment_id = nil, content_view_id = nil)
        @current_repositories ||= @smart_proxy.pulp_repositories
        puppet_repo_ids = []
        @current_repositories.each do |repo|
          found_puppet = Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo[:id]).first
          puppet_repo_ids << found_puppet.id if found_puppet
        end
        puppet_repos = Katello::ContentViewPuppetEnvironment.where(:id => puppet_repo_ids)
        puppet_repos = puppet_repos.where(:environment_id => environment_id) if environment_id
        puppet_repos = puppet_repos.in_content_view(content_view_id) if content_view_id
        puppet_repos
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

      def needs_importer_updates(repos)
        repos.select do |repo|
          repo_details = repo.backend_service(self.smart_proxy).backend_data
          next unless repo_details
          capsule_importer = repo_details["importers"][0]
          !importer_matches?(repo, capsule_importer)
        end
      end

      def needs_distributor_updates(repos)
        repos.select do |repo|
          repo_details = repo.backend_service(smart_proxy).backend_data
          next unless repo_details
          !distributors_match?(repo, repo_details["distributors"])
        end
      end

      def importer_matches?(repo, capsule_importer)
        generated_importer = repo.backend_service(self.smart_proxy).generate_importer
        capsule_importer.try(:[], 'importer_type_id') == generated_importer.id &&
            generated_importer.config.compact == capsule_importer['config'].compact
      end

      def distributors_match?(repo, capsule_distributors)
        generated_distributor_configs = repo.backend_service(self.smart_proxy).generate_distributors
        generated_distributor_configs.all? do |gen_dist|
          type = gen_dist.class.type_id
          found_on_capsule = capsule_distributors.find { |dist| dist['distributor_type_id'] == type }
          found_on_capsule && filtered_distribution_config_equal?(gen_dist.config, found_on_capsule['config'])
        end
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

      private

      def filtered_distribution_config_equal?(generated_config, actual_config)
        generated = generated_config.clone
        actual = actual_config.clone
        #We store 'default' checksum type as nil, but pulp will default to sha256, so if we haven't set it, ignore it
        if generated.keys.include?('checksum_type') && generated['checksum_type'].nil?
          generated.delete('checksum_type')
          actual.delete('checksum_type')
        end
        generated.compact == actual.compact
      end
    end
  end
end
