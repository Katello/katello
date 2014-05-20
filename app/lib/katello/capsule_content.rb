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

    def self.with_environment(environment)
      SmartProxy.joins(:capsule_lifecycle_environments).
          where(katello_capsule_lifecycle_environments:
                { lifecycle_environment_id: environment.id }).map do |proxy|
        self.new(proxy)
      end
    end
  end
end
