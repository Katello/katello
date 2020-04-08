module Actions
  module Pulp
    module Orchestration
      module Repository
        class UploadContent < Pulp::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, file, unit_type_id)
            sequence do
              upload_request = plan_action(Pulp::Repository::CreateUploadRequest)
              plan_action(Pulp::Repository::UploadFile,
                          upload_id: upload_request.output[:upload_id],
                          file: file[:path])
              plan_action(Pulp::Repository::ImportUpload,
                          repository, smart_proxy,
                          pulp_id: repository.pulp_id,
                          unit_type_id: unit_type_id,
                          unit_key: unit_key(file, repository),
                          upload_id: upload_request.output[:upload_id])
              plan_action(Pulp::Repository::DeleteUploadRequest,
                          upload_id: upload_request.output[:upload_id])
              plan_self(:subaction_output => nil)
            end
          end

          def unit_key(file, repository)
            return {} unless repository.file?
            {
              :checksum => Digest::SHA256.hexdigest(File.read(file[:path])),
              :name => file[:filename],
              :size => File.size(file[:path])
            }
          end
        end
      end
    end
  end
end
