module Actions
  module Pulp3
    module Repository
      class SaveArtifact < Pulp3::Abstract
        def plan(file, repository, tasks, unit_type_id, options = {})
          options[:file_name] = file[:filename]
          plan_self(:repository_id => repository.id, :tasks => tasks, :unit_type_id => unit_type_id, :options => options)
        end

        def run
          artifact_href = input[:tasks].last[:created_resources].first
          content_type = input[:unit_type_id]
          content_backend_service = SmartProxy.pulp_master.content_service(content_type)
          upload_options = {artifact: artifact_href}.merge(input[:options])
          content = content_backend_service.create_content(upload_options.with_indifferent_access)
          content_unit = content_backend_service.content_api.create(content)
          output[:content_unit_href] = content_unit.pulp_href
        end
      end
    end
  end
end
