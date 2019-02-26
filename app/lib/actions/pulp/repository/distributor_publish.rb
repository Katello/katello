module Actions
  module Pulp
    module Repository
      class DistributorPublish < Pulp::AbstractAsyncTask
        middleware.use Actions::Middleware::SkipIfMatchingContent

        def plan(repository, smart_proxy, options)
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :options => options, :dependency => options[:dependency])
        end

        def invoke_external_task
          repo = ::Katello::Repository.find_by(:id => input[:repository_id])
          if repo.nil?
            repo = ::Katello::ContentViewPuppetEnvironment.find_by(:id => input[:repository_id]).nonpersisted_repository
          end
          smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
          repo.backend_service(smart_proxy).distributor_publish(input[:options])
        end

        def humanized_name
          _("Repository metadata publish")
        end
      end
    end
  end
end
