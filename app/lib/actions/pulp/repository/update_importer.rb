module Actions
  module Pulp
    module Repository
      class UpdateImporter < Pulp::Abstract
        input_format do
          param :repo_id
          param :id
          param :config
          param :capsule_id
        end

        def run
          output[:response] = pulp_resources.repository.
              update_importer(*input.values_at(:repo_id, :id, :config))
        end

        def run_progress_weight
          0.01
        end
      end
    end
  end
end
