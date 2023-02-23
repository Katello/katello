module Actions
  module Pulp3
    module Repository
      class ReclaimSpace < Pulp3::AbstractAsyncTask
        def plan(repo, smart_proxy = SmartProxy.pulp_primary)
          action_subject(repo)
          repository_hrefs = ::Katello::Pulp3::RepositoryReference.default_cv_repository_hrefs([repo], repo.organization)
          plan_self(repository_hrefs: repository_hrefs, smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(SmartProxy.find(input[:smart_proxy_id])).
            repositories_reclaim_space_api.reclaim(repo_hrefs: input[:repository_hrefs])
        end
      end
    end
  end
end
