module Actions
  module Pulp3
    module Repository
      class ReclaimSpace < Pulp3::AbstractAsyncTask
        def plan(repositories, smart_proxy = SmartProxy.pulp_primary)
          repositories = [repositories] if repositories.is_a?(::Katello::Repository)
          if repositories.empty?
            fail _("No repositories selected.")
          end
          repositories = repositories.select { |repo| repo.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND }
          if repositories.empty?
            fail _("Only On Demand repositories may have space reclaimed.")
          end
          repository_hrefs = ::Katello::Pulp3::RepositoryReference.default_cv_repository_hrefs(repositories, Organization.current)
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
