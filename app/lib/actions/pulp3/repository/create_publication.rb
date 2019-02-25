module Actions
  module Pulp3
    module Repository
      class CreatePublication < Pulp3::AbstractAsyncTask
        def plan(repository, smart_proxy, options)
          sequence do
            action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :options => options)
            plan_action(SavePublication, repository, action.output[:pulp_tasks])
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          if repository.publication_href.nil? || input[:options][:force]
            output[:response] = repository.backend_service(smart_proxy).create_publication
          else
            []
          end
        end
      end
    end
  end
end
