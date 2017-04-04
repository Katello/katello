module Katello
  class CapsuleContent
    attr_reader :capsule

    def initialize(capsule)
      # capsule is a smart proxy with pulp feature
      @capsule = capsule
    end

    def lifecycle_environments(organization_id = nil)
      scope = @capsule.lifecycle_environments
      scope = scope.where(organization_id: organization_id) if organization_id
      scope
    end

    def pulp_server
      Katello::Pulp::Server.config(pulp_url, User.remote_user)
    end

    def repos_available_to_capsule(environments = nil, content_view = nil)
      environments = lifecycle_environments if environments.nil?
      yum_repos = Katello::Repository.in_environment(environments)
      yum_repos = yum_repos.in_content_views([content_view]) if content_view
      yum_repos = yum_repos.find_all { |repo| repo.node_syncable? }

      puppet_environments = Katello::ContentViewPuppetEnvironment.in_environment(environments)
      puppet_environments = puppet_environments.in_content_view(content_view) if content_view
      yum_repos + puppet_environments
    end

    def add_lifecycle_environment(environment)
      @capsule.lifecycle_environments << environment
    end

    def remove_lifecycle_environment(environment)
      @capsule.lifecycle_environments.find(environment)
      unless @capsule.lifecycle_environments.destroy(environment)
        fail _("Could not remove the lifecycle environment from the capsule")
      end
    rescue ActiveRecord::RecordNotFound
      raise _("Lifecycle environment was not attached to the capsule; therefore, no changes were made.")
    end

    def available_lifecycle_environments(organization_id = nil)
      scope = Katello::KTEnvironment.not_in_capsule(@capsule)
      scope = scope.where(organization_id: organization_id) if organization_id
      scope
    end

    def sync_tasks
      ForemanTasks::Task.for_resource(self.capsule)
    end

    def active_sync_tasks
      sync_tasks.where(:result => 'pending')
    end

    def last_failed_sync_tasks
      sync_tasks.where('started_at > ?', last_sync_time).where.not(:result => 'pending')
    end

    def last_sync_time
      task = sync_tasks.where.not(:ended_at => nil).where(:result => 'success').order(:ended_at).last
      task.ended_at unless task.nil?
    end

    def environment_syncable?(env)
      last_sync_time.nil? || env.content_view_environments.where('updated_at > ?', last_sync_time).any?
    end

    def current_repositories_data(environment = nil, content_view = nil)
      @pulp_repositories ||= @capsule.pulp_repositories

      repos = Katello::Repository
      repos = repos.in_environment(environment) if environment
      repos = repos.in_content_views([content_view]) if content_view
      puppet_envs = Katello::ContentViewPuppetEnvironment
      puppet_envs = puppet_envs.in_environment(environment) if environment
      puppet_envs = puppet_envs.in_content_view(content_view) if content_view

      repo_ids = repos.pluck(:pulp_id) + puppet_envs.pluck(:pulp_id)

      @pulp_repositories.select { |r| repo_ids.include?(r['id']) }
    end

    def cancel_sync
      active_sync_tasks.map(&:cancel)
    end

    def ==(other)
      other.class == self.class && other.capsule == capsule
    end

    def default_capsule?
      @capsule.default_capsule?
    end

    def orphaned_repos
      @capsule.pulp_repositories.map { |x| x["id"] } - current_repositories.map { |x| x.pulp_id }
    end

    # shows repos available both in katello and on the capsule.
    def current_repositories(environment_id = nil, content_view_id = nil)
      @current_repositories ||= @capsule.pulp_repositories
      katello_repo_ids = []
      puppet_repo_ids = []

      @current_repositories.each do |repo|
        found_repo = Katello::Repository.where(:pulp_id => repo[:id]).first
        if !found_repo
          found_puppet = Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo[:id]).first
          puppet_repo_ids << found_puppet.id if found_puppet
        else
          katello_repo_ids << found_repo.id if found_repo
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

    def pulp_url
      "https://" + self.capsule.hostname + "/pulp/api/v2/"
    end

    def pulp_repo_facts(pulp_id)
      self.pulp_server.extensions.repository.retrieve_with_details(pulp_id)
    rescue RestClient::ResourceNotFound
      nil
    end

    def ping_pulp
      ::Katello::Ping.pulp_without_auth(self.pulp_url)
    rescue Errno::EHOSTUNREACH, Errno::ECONNREFUSED, RestClient::Exception => error
      raise ::Katello::Errors::CapsuleCannotBeReached, _("%s is unreachable. %s" % [@capsule.name, error])
    end

    def verify_ueber_certs
      self.capsule.organizations.each do |org|
        Cert::Certs.verify_ueber_cert(org)
      end
    end

    def self.with_environment(environment, include_default = false)
      features = [SmartProxy::PULP_NODE_FEATURE]
      features << SmartProxy::PULP_FEATURE if include_default

      scope = SmartProxy.with_features(features).joins(:capsule_lifecycle_environments).
          where(katello_capsule_lifecycle_environments: { lifecycle_environment_id: environment.id })

      scope.map { |proxy| self.new(proxy) }
    end

    def self.default_capsule
      proxy = SmartProxy.with_features(SmartProxy::PULP_FEATURE).first
      self.new(proxy) if proxy
    end

    def self.sync_needed?(environment)
      ::Katello::CapsuleContent.with_environment(environment).any?
    end
  end
end
