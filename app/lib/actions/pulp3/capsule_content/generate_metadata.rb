module Actions
  module Pulp3
    module CapsuleContent
      class GenerateMetadata < Pulp3::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged
        def plan(repository, smart_proxy, options = {})
          options[:contents_changed] = (options && options.key?(:contents_changed)) ? options[:contents_changed] : true
          sequence do
            unless repository.repository_type.pulp3_skip_publication
              plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id,
                         :options => options).output
            end
            plan_action(RefreshDistribution, repository, smart_proxy,
                          :contents_changed => options[:contents_changed])
          end
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id])
          #yum repositories use metadata mirroring always, so we should never
          # regenerate metadata on proxies
          if repository.yum?
            []
          else
            smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
            repository.backend_service(smart_proxy).with_mirror_adapter.create_publication
          end
        end
      end
    end
  end
end
