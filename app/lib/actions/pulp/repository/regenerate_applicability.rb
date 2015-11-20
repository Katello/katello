module Actions
  module Pulp
    module Repository
      class RegenerateApplicability < Pulp::AbstractAsyncTask
        middleware.use Actions::Middleware::ExecuteIfContentsChanged

        input_format do
          param :pulp_id
          param :contents_changed
        end

        def invoke_external_task
          pulp_extensions.repository.regenerate_applicability_by_ids([input[:pulp_id]])
        end
      end
    end
  end
end
