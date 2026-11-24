module Actions
  module Pulp3
    module Orchestration
      module Repository
        class RefreshIfNeeded < Pulp3::AbstractAsyncTask
          def plan(repository, smart_proxy, _options = {})
            sequence do
              action = plan_self(repository_id: repository.id, smart_proxy_id: smart_proxy.id)
              if repository.docker? && smart_proxy.pulp_primary?
                plan_action(::Actions::Pulp3::Repository::SaveDistributionReferences, repository, smart_proxy, action.output,
                            existing_only: true)
              end
            end
          end

          def invoke_external_task
            repo = ::Katello::Repository.find(input[:repository_id])
            tasks = repo.backend_service(smart_proxy).refresh_if_needed
            repo.docker? && smart_proxy.pulp_primary? ? Array(tasks).flatten.compact : tasks
          end
        end
      end
    end
  end
end
