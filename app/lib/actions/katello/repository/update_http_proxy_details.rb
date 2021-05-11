module Actions
  module Katello
    module Repository
      class UpdateHttpProxyDetails < Actions::EntryAction
        def plan(repository)
          plan_action(
            Actions::Pulp3::Repository::UpdateRemote,
            repository,
            SmartProxy.pulp_primary)
        end
      end
    end
  end
end
