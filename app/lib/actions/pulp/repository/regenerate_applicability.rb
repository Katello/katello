module Actions
  module Pulp
    module Repository
      class RegenerateApplicability < Pulp::AbstractAsyncTaskGroup
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :repository_id
          param :capsule_id
          param :contents_changed
        end

        def invoke_external_task
          capsule_id = input[:capsule_id] || SmartProxy.default_capsule!.id
          repo = ::Katello::Repository.find(input[:repository_id])
          repo.backend_service(smart_proxy(capsule_id)).regenerate_applicability
        end
      end
    end
  end
end
