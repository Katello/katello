module Actions
  module Pulp3
    module Repository
      class CreatePublication < Pulp3::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, smart_proxy, options)
          sequence do
            action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :contents_changed => options[:contents_changed], :options => options)
            plan_action(SavePublication, repository, action.output, :contents_changed => options[:contents_changed])
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
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
