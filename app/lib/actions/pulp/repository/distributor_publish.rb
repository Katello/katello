module Actions
  module Pulp
    module Repository
      class DistributorPublish < Pulp::AbstractAsyncTask
        middleware.use Actions::Middleware::SkipIfMatchingContent

        def plan(repository, smart_proxy, options)
          options = {:smart_proxy_id => smart_proxy.id, :options => options, :dependency => options[:dependency]}
          if repository.is_a?(Katello::ContentViewPuppetEnvironment)
            options[:content_view_puppet_environment_id] = repository.id
          else
            options[:repository_id] = repository.id
          end
          plan_self(options)
        end

        def invoke_external_task
          if input[:repository_id]
            repo = ::Katello::Repository.find_by(:id => input[:repository_id])
          else
            repo = ::Katello::ContentViewPuppetEnvironment.find_by(:id => input[:repository_id]).nonpersisted_repository
          end

          repo.backend_service(smart_proxy(input[:smart_proxy_id])).distributor_publish(input[:options])
        end

        def humanized_name
          _("Repository metadata publish")
        end
      end
    end
  end
end
