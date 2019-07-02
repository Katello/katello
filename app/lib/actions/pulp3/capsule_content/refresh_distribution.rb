module Actions
  module Pulp3
    module CapsuleContent
      class RefreshDistribution < Pulp3::AbstractAsyncTask
        include Helpers::Presenter
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        def plan(repository, smart_proxy, options = {})
          action = plan_self(:repository_id => repository.id,
                             :smart_proxy_id => smart_proxy.id,
                             :options => options)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
          options = input[:options]
          tasks = options[:tasks]
          if options[:use_repository_version]
            output[:response] = repo.backend_service(smart_proxy).refresh_mirror_distributions(:use_repository_version => true)
          elsif tasks && tasks[:pulp_tasks] && tasks[:pulp_tasks].first
            publication_href = tasks[:pulp_tasks].first[:created_resources].first
            if publication_href
              repo = ::Katello::Repository.find(input[:repository_id])
              output[:response] = repo.backend_service(smart_proxy).refresh_mirror_distributions(:publication => publication_href)
            end
          end
        end
      end
    end
  end
end
