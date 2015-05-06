module Actions
  module Pulp
    module Repository
      class ImportUpload < Pulp::AbstractAsyncTask
        input_format do
          param :pulp_id
          param :unit_type_id
          param :upload_id
        end

        def invoke_external_task
          pulp_resources.content.import_into_repo(input[:pulp_id],
                                                   input[:unit_type_id],
                                                   input[:upload_id],
                                                   {},
                                                    unit_metadata: {})
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
