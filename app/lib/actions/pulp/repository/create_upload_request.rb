module Actions
  module Pulp
    module Repository
      class CreateUploadRequest < Pulp::Abstract
        input_format do
        end

        output_format do
          param :response
          param :upload_id
        end

        def run
          output[:response] = pulp_resources.content.create_upload_request
          output[:upload_id] = output[:response][:upload_id]
        end
      end
    end
  end
end
