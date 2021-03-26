module Actions
  module Pulp
    module Repository
      class DistributorPublish < Pulp::AbstractAsyncTask
        middleware.use Actions::Middleware::SkipIfMatchingContent

        def plan(repository, smart_proxy, options)
          options = {:smart_proxy_id => smart_proxy.id, :options => options, :dependency => options[:dependency]}
          options[:repository_id] = repository.id
          plan_self(options)
        end

        def invoke_external_task
          repo = ::Katello::Repository.find_by(:id => input[:repository_id])
          repo.clear_smart_proxy_sync_histories if smart_proxy(input[:smart_proxy_id]).pulp_primary?
          repo.backend_service(smart_proxy(input[:smart_proxy_id])).distributor_publish(input[:options])
        end

        def humanized_name
          _("Repository metadata publish")
        end
      end
    end
  end
end
