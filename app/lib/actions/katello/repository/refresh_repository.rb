module Actions
  module Katello
    module Repository
      class RefreshRepository < Actions::Base
        def plan(repo, options = {})
          User.as_anonymous_admin do
            repo = ::Katello::Repository.find(repo.id)
            plan_action(Pulp::Repository::Refresh, repo, :capsule_id => SmartProxy.default_capsule!.id, :dependency => options[:dependency])
            plan_self(:name => repo.name, :dependency => options[:dependency])
          end
        end
      end
    end
  end
end
