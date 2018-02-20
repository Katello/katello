module Actions
  module Pulp
    module Consumer
      class GenerateApplicability < Pulp::AbstractAsyncTask
        input_format do
          param :uuids, Array
        end

        def invoke_external_task
          if input[:uuids].length == 1
            begin
              pulp_resources.consumer.regenerate_applicability_by_id(input[:uuids].first)
            rescue RestClient::ResourceNotFound
              Rails.logger.warn("Pulp consumer %s not found." % input[:uuids].first)
            end
          else
            pulp_extensions.consumer.regenerate_applicability_by_ids(input[:uuids])
          end
        end
      end
    end
  end
end
