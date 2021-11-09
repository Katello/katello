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
          backend = repository.backend_service(smart_proxy).with_mirror_adapter
          #yum repositories use metadata mirroring always, so we should never
          # regenerate metadata on proxies.  but if there is no publication,
          # it means the repo was likely empty and syncing didn't generate one
          if repository.yum? && backend.publication_href.present?
            []
          else
            backend.create_publication
          end
        end
      end
    end
  end
end
