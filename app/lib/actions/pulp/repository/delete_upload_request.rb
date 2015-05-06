module Actions
  module Pulp
    module Repository
      class DeleteUploadRequest < Pulp::Abstract
        input_format do
          param :upload_id
        end

        output_format do
          param :response
        end

        def run
          output[:response] = pulp_resources.content.delete_upload_request(input[:upload_id])
        end
      end
    end
  end
end
