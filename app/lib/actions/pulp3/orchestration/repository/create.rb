module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Create < Pulp3::Abstract
          def plan(repository, smart_proxy, force = false)
            sequence do
              create_action = plan_action(Actions::Pulp3::Repository::Create, repository, smart_proxy, force)
              plan_action(Actions::Pulp3::Repository::SaveVersion, repository, repository_details: create_action.output[:response])

              if repository.content_view.default? || !smart_proxy.pulp_primary?
                plan_action(Actions::Pulp3::Repository::CreateRemote, repository, smart_proxy)
              end
            end
          end
        end
      end
    end
  end
end
