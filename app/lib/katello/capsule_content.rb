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

    def pulp_repos(environments = lifecycle_environments, content_view = nil)
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
        fail "could not remove the lifecycle environment form capsule"
      end
    end

    def available_lifecycle_environments(organization_id = nil)
      scope = Katello::KTEnvironment.not_in_capsule(@capsule)
      scope = scope.where(organization_id: organization_id) if organization_id
      scope
    end

    delegate :uuid, :to => :consumer, :prefix => true

    def consumer
      @consumer ||= System.where(name: @capsule.name).first
      unless @consumer
        fail Errors::CapsuleContentMissingConsumer, _("Could not find Content Host with exact name '%s', verify the Capsule is registered with that name.")  %
            @capsule.name
      end
      @consumer
    end

    def ==(other)
      other.class == self.class && other.capsule == capsule
    end

    def default_capsule?
      @capsule.default_capsule?
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
  end
end
