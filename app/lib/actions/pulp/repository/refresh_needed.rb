module Actions
  module Pulp
    module Repository
      class RefreshNeeded < Pulp::AbstractAsyncTask
        input_format do
          param :smart_proxy_id
          param :environment_id
          param :content_view_id
          param :repository_id
        end

        def plan(smart_proxy, options = {})
          plan_self(:smart_proxy_id => smart_proxy.id, :environment_id => options[:environment_id], :content_view_id => options[:content_view_id], :repository_id => options[:repository_id])
        end

        def invoke_external_task
          tasks = []
          environment = ::Katello::KTEnvironment.find_by(:id => input[:environment_id]) if input[:environment_id]
          repository = ::Katello::Repository.find_by(:id => input[:repository_id]) if input[:repository_id]
          if repository.nil? && input[:repository_id]
            repository = ::Katello::ContentViewPuppetEnvironment.find(input[:repository_id])
            repository = repository.nonpersisted_repository
          end
          content_view = ::Katello::ContentView.find_by(:id => input[:content_view_id]) if input[:content_view_id]
          smart_proxy = SmartProxy.find(input[:smart_proxy_id])
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)

          need_updates = smart_proxy_service.repos_needing_updates(environment, content_view, repository)
          need_updates.each do |repo|
            tasks += repo.backend_service(smart_proxy).refresh
          end
          tasks
        end
      end
    end
  end
end
