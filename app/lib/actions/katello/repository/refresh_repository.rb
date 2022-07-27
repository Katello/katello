module Actions
  module Katello
    module Repository
      class RefreshRepository < Actions::Base
        def plan(repo, options = {})
          User.as_anonymous_admin do
            repo = ::Katello::Repository.find(repo.id)
            plan_action(Actions::Pulp3::Orchestration::Repository::RefreshIfNeeded,
                             repo, SmartProxy.default_capsule!, :dependency => options[:dependency])
            repo.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(::Actions::Pulp3::Orchestration::AlternateContentSource::RefreshRemote, smart_proxy_acs)
            end
            plan_self(:name => repo.name, :dependency => options[:dependency])
          end
        end
      end
    end
  end
end
