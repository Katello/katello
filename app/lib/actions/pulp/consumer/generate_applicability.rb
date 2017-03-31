module Actions
  module Pulp
    module Consumer
      class GenerateApplicability < Pulp::AbstractAsyncTask
        input_format do
          param :uuids, Array
        end

        def invoke_external_task
          if input[:uuids].length == 1
            pulp_resources.consumer.regenerate_applicability_by_id(input[:uuids].first)
          else
            pulp_extensions.consumer.regenerate_applicability_by_ids(input[:uuids])
          end
        end
      end
    end
  end
end
