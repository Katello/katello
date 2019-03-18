module Actions
  module Katello
    module Repository
      class Clear < Actions::Base
        def plan(repo)
          plan_action(Actions::Pulp::Repository::Clear, repo, SmartProxy.pulp_master)
        end
      end
    end
  end
end
