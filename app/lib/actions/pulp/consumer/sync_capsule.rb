module Actions
  module Pulp
    module Consumer
      class SyncCapsule < ::Actions::Pulp::AbstractContentTask
        input_format do
          param :capsule_id, Integer
          param :repo_pulp_id, String
        end

        def humanized_name
          _("Synchronize capsule content")
        end

        def invoke_external_task
          pulp_resources.repository.sync(input[:repo_pulp_id])
        end
      end
    end
  end
end
