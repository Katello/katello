module Actions
  module Pulp3
    module CapsuleContent
      class CreatePublication < Pulp3::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, smart_proxy, options)
          sequence do
            if !::Katello::RepositoryTypeManager.find(repository.content_type).pulp3_skip_publication
              action = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :contents_changed => options[:contents_changed], :options => options)
              plan_action(RefreshDistribution, repository, smart_proxy,
                            :tasks => action.output,
                            :use_repository_version => false,
                            :contents_changed => options[:contents_changed])
            else
              plan_action(RefreshDistribution, repository, smart_proxy,
                            :tasks => action.output,
                            :use_repository_version => true,
                            :contents_changed => options[:contents_changed])
            end
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
          output[:response] = repository.backend_service(smart_proxy).create_mirror_publication
        end
      end
    end
  end
end
