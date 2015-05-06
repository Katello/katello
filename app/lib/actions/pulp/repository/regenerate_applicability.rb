module Actions
  module Pulp
    module Repository
      class RegenerateApplicability < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
        end

        def invoke_external_task
          pulp_extensions.repository.regenerate_applicability_by_ids([input[:pulp_id]])
        end
      end
    end
  end
end
