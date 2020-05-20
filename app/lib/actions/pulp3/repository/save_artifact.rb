module Actions
  module Pulp3
    module Repository
      class SaveArtifact < Pulp3::AbstractAsyncTask
        def plan(file, repository, smart_proxy, tasks, unit_type_id, options = {})
          options[:file_name] = file[:filename]
          plan_self(:repository_id => repository.id, :smart_proxy_id => smart_proxy.id, :tasks => tasks, :unit_type_id => unit_type_id, :options => options)
        end

        def invoke_external_task
          artifact_href = input[:tasks].last[:created_resources].first
          content_type = input[:unit_type_id]
          content_backend_service = SmartProxy.pulp_primary.content_service(content_type)
          output[:pulp_tasks] = [content_backend_service.content_api_create(relative_path: input[:options][:file_name], artifact: artifact_href)]
        end
      end
    end
  end
end
