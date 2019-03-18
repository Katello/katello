module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Clear < Actions::Base
        def plan(repo)
          plan_action(Pulp::Repository::RemoveUnits, content_view_puppet_environment_id: repo.id)
        end
      end
    end
  end
end
