module Actions
  module Pulp
    module Repository
      class UploadFile < Pulp::Abstract
        input_format do
          param :upload_id
          param :file
        end

        def run
          File.open(input[:file], "rb") do |file|
            offset = 0
            while (chunk = file.read(upload_chunk_size))
              pulp_resources.content.upload_bits(input[:upload_id], offset, chunk)
              offset += upload_chunk_size
            end
          end
        end

        private

        def upload_chunk_size
          SETTINGS[:katello][:pulp][:upload_chunk_size]
        end
      end
    end
  end
end
