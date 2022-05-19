module Actions
  module Pulp3
    module Repository
      class SaveDistributionReferences < Pulp3::Abstract
        def plan(repository, smart_proxy, tasks, options = {})
          plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id, tasks: tasks, contents_changed: options[:contents_changed])
        end

        def run
          if input[:tasks] && input[:tasks][:pulp_tasks] && input[:tasks][:pulp_tasks].first
            distribution_hrefs = input[:tasks][:pulp_tasks].map { |task| task[:created_resources].first }
            distribution_hrefs.compact!
            repo = ::Katello::Repository.find(input[:repository_id])
            if distribution_hrefs.any?
              repo.backend_service(smart_proxy, true).save_distribution_references(distribution_hrefs)
            else
              repo.backend_service(smart_proxy, true).update_distribution
            end
          end
        end
      end
    end
  end
end
