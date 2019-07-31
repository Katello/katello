module Actions
  module Pulp3
    module Repository
      class SaveArtifact < Pulp3::Abstract
        def plan(file, repository, tasks, unit_type_id)
          file_name = file[:filename]
          plan_self(:file_name => file_name, :repository_id => repository.id, :tasks => tasks, :unit_type_id => unit_type_id)
        end

        def run
          artifact_href = input[:tasks].last[:created_resources].first
          content_type = input[:unit_type_id]
          repo = ::Katello::Repository.find(input[:repository_id])
          content_backend_service = SmartProxy.pulp_master.content_service(content_type)
          data = content_backend_service.content_class.new({relative_path: input[:file_name], _artifact: artifact_href})
          content_unit = content_backend_service.content_api.create(data)
          output[:content_unit_href] = content_unit._href
        end
      end
    end
  end
end
