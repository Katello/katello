module Actions
  module Pulp
    module Consumer
      class GenerateApplicability <  Pulp::AbstractAsyncTask
        input_format do
          param :uuids, Array
        end

        def invoke_external_task
          pulp_extensions.consumer.regenerate_applicability_by_ids(input[:uuids])
        end
      end
    end
  end
end
