module Actions
  module Pulp
    module Orchestration
      module Repository
        class Sync < Pulp::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, options)
            sequence do
              options.merge!(:repo_id => repository.id, :smart_proxy_id => smart_proxy.id)
              action_output = plan_action(Actions::Pulp::Repository::Sync, options).output
              plan_self(:subaction_output => action_output)
            end
          end
        end
      end
    end
  end
end
