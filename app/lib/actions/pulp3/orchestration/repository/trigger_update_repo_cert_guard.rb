module Actions
  module Pulp3
    module Orchestration
      module Repository
        class TriggerUpdateRepoCertGuard < Pulp3::Abstract
          def plan(repository, smart_proxy)
            plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id)
          end

          def run
            repository = ::Katello::Repository.find(input[:repository_id])
            ForemanTasks.async_task(::Actions::Pulp3::Repository::UpdateCvRepositoryCertGuard, repository, smart_proxy)
          end

          def humanized_name
            _("Updating repository authentication configuration")
          end
        end
      end
    end
  end
end
