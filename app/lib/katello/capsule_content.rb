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

    def pulp_repos(environment)
      yum_repos = Katello::Repository.in_environment(environment).find_all do |repo|
        repo.node_syncable?
      end
      puppet_environments = Katello::ContentViewPuppetEnvironment.in_environment(environment)
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

    # Pulp consumer UUID associated with the capsule
    def consumer_uuid
      @consumer_uuid ||= System.where(name: @capsule.name).first!.uuid
    end

    def default_capsule?
      @capsule.default_capsule?
    end

    def self.with_environment(environment, include_default = false)
      scope = SmartProxy.joins(:capsule_lifecycle_environments).
          where(katello_capsule_lifecycle_environments: { lifecycle_environment_id: environment.id })

      unless include_default
        server_fqdn = Facter.value(:fqdn) || SETTINGS[:fqdn]
        scope = scope.where("#{ SmartProxy.table_name }.name not in (?)", server_fqdn)
      end

      scope.map { |proxy| self.new(proxy) }
    end

    def self.default_capsule
      proxy = SmartProxy.with_features(SmartProxy::PULP_FEATURE).first
      self.new(proxy) if proxy
    end
  end
end
