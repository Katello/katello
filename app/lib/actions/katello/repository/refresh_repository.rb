module Actions
  module Katello
    module Repository
      class RefreshRepository < Actions::Base
        include Actions::Katello::PulpSelector

        def plan(repo, options = {})
          User.as_anonymous_admin do
            repo = ::Katello::Repository.find(repo.id)
            plan_pulp_action([Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded,
                              Actions::Pulp::Orchestration::Repository::RefreshIfNeeded],
                             repo, SmartProxy.default_capsule!, :dependency => options[:dependency])
            plan_self(:name => repo.name, :dependency => options[:dependency])
          end
        end
      end
    end
  end
end
