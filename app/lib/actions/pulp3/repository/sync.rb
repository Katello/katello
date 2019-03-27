module Actions
  module Pulp3
    module Repository
      class Sync < Pulp3::AbstractAsyncTask
        input_format do
          param :smart_proxy_id
          param :pulp_id
          param :task_id # In case we need just pair this action with existing sync task
          param :source_url # allow overriding the feed URL
          param :options # Pulp sync options
        end

        def invoke_external_task
            repo = ::Katello::Repository.find_by(:pulp_id => input[:pulp_id])
            output[:pulp_tasks] = repo.backend_service(::SmartProxy.pulp_master).sync
        end

        def external_task=(tasks)
          output[:contents_changed] = false
          output[:create_version] = true
          super
        end
      end
    end
  end
end