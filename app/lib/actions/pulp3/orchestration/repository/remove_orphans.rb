module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RemoveOrphans < Pulp3::Abstract
          def plan(smart_proxy)
            plan_action(Actions::Pulp3::Repository::DeleteOrphanRepositoryVersions, SmartProxy.pulp_master) if smart_proxy.pulp3_enabled?
          end
        end
      end
    end
  end
end
