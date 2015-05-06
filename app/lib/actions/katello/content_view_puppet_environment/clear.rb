module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Clear < Actions::Base
        def plan(repo)
          plan_action(Pulp::Repository::RemovePuppetModule, pulp_id: repo.pulp_id)
        end
      end
    end
  end
end
