module Actions
  module Pulp
    module Repository
      class AssociateImporter < Pulp::AbstractAsyncTask
        input_format do
          param :repo_id
          param :type_id
          param :config
          param :hash
          param :capsule_id
        end

        def invoke_external_task
          pulp_resources.repository.associate_importer(*input.values_at(:repo_id, :type_id, :config))
        end
      end
    end
  end
end
