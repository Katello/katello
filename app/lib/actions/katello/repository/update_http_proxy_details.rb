module Actions
  module Katello
    module Repository
      class UpdateHttpProxyDetails < Actions::EntryAction
        include Actions::Katello::PulpSelector

        def plan(repository)
          plan_pulp_action(
            [Actions::Pulp::Orchestration::Repository::Refresh,
             Actions::Pulp3::Repository::UpdateRemote],
            repository,
            SmartProxy.pulp_primary)
        end
      end
    end
  end
end
