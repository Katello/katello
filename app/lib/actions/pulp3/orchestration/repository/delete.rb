module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Delete < Pulp3::Abstract
          def plan(repository, smart_proxy)
            sequence do
              plan_action(Actions::Pulp3::Repository::DeleteRemote, repository.id, smart_proxy) if repository.remote_href
              plan_action(Actions::Pulp3::Repository::DeleteDistributions, repository.id, smart_proxy)

              if repository.content_view.default?
                # Legacy Pulp push repositories are deleted through the distribution.
                if repository.root.is_container_push
                  reference = repository.backend_service(smart_proxy).repository_reference
                  return if reference&.repository_href&.include?('/container/container-push/')
                end

                # We're deleting the library instance, so just delete the whole pulp3 repo
                plan_action(Actions::Pulp3::Repository::Delete, repository.id, smart_proxy)
              elsif repository.environment.nil?
                # We're deleting the archived instance, so delete the version
                plan_action(Actions::Pulp3::Repository::DeleteVersion, repository, smart_proxy)
              end
            end
          end
        end
      end
    end
  end
end
