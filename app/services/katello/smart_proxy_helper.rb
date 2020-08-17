module Katello
  class SmartProxyHelper
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

    def lifecycle_environment_check(environment = nil, repository = nil)
      environment = repository.environment if repository

      if environment && !self.smart_proxy.lifecycle_environments.include?(environment)
        fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
      end
    end

    def combined_repos_available_to_capsule(environment = nil, content_view = nil, repository = nil)
      lifecycle_environment_check(environment, repository)
      if repository
        [repository]
      else
        repositories_available_to_capsule(environment, content_view) + puppet_environments_available_to_capsule(environment, content_view)
      end
    end

    def repositories_available_to_capsule(environments, content_view)
      environments = @smart_proxy.lifecycle_environments if environments.nil?
      yum_repos = Katello::Repository.in_environment(environments)
      yum_repos = yum_repos.in_content_views([content_view]) if content_view
      yum_repos.smart_proxy_syncable
    end

    def puppet_environments_available_to_capsule(environments, content_view)
      environments = @smart_proxy.lifecycle_environments if environments.nil?
      puppet_environments = Katello::ContentViewPuppetEnvironment.in_environment(environments)
      puppet_environments = puppet_environments.in_content_view(content_view) if content_view
      puppet_environments
    end
  end
end
