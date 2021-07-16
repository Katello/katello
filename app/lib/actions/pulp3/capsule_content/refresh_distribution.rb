module Actions
  module Pulp3
    module CapsuleContent
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repository, smart_proxy, options = {})
          plan_self(:repository_id => repository.id,
                             :smart_proxy_id => smart_proxy.id,
                             :options => options)
        end

        def invoke_external_task
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          options = input[:options]
          tasks = options[:tasks]
          repo = ::Katello::Repository.find(input[:repository_id])
          if options[:use_repository_version]
            repo.backend_service(smart_proxy).with_mirror_adapter.refresh_distributions(:use_repository_version => true)
          elsif tasks && tasks[:pulp_tasks] && tasks[:pulp_tasks].first
            publication_href = ::Katello::Pulp3::Task.publication_href(tasks[:pulp_tasks])
            repo.backend_service(smart_proxy).with_mirror_adapter.refresh_distributions(:publication => publication_href) if publication_href.any?
          end
        end
      end
    end
  end
end
