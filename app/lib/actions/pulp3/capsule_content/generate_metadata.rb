module Actions
  module Pulp3
    module CapsuleContent
      class GenerateMetadata < Pulp3::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, smart_proxy, options = {})
          options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
          sequence do
            if !::Katello::RepositoryTypeManager.find(repository.content_type).pulp3_skip_publication
              action_output = plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id,
                                 :options => options).output
              plan_action(RefreshDistribution, repository, smart_proxy,
                            :tasks => action_output,
                            :use_repository_version => false,
                            :contents_changed => options[:contents_changed])
            else
              plan_action(RefreshDistribution, repository, smart_proxy,
                            :use_repository_version => true,
                            :contents_changed => options[:contents_changed])
            end
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          output[:response] = repository.backend_service(smart_proxy).with_mirror_adapter.create_publication
        end
      end
    end
  end
end
