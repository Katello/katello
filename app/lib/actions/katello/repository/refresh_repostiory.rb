module Actions
  module Katello
    module Repository
      class RefreshRepository < Actions::Base
        def plan(repo)
          User.as_anonymous_admin do
            repo = ::Katello::Repository.find(repo.id)
            plan_action(Pulp::Repository::Refresh, repo)
          end
        end
      end
    end
  end
end
