module Actions
  module Pulp3
    module Repository
      class SaveDistributionReferences < Pulp3::Abstract
        def plan(repository, smart_proxy, tasks)
          plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id, tasks: tasks)
        end

        def run
          if input[:tasks] && input[:tasks].first
            distribution_hrefs = input[:tasks].map { |task| task[:created_resources].first }
            distribution_hrefs.compact!
            if distribution_hrefs.any?
              repo = ::Katello::Repository.find(input[:repository_id])
              repo.backend_service(smart_proxy).save_distribution_references(distribution_hrefs)
            end
          end
        end
      end
    end
  end
end
