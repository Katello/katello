module Actions
  module Pulp
    module Repository
      class DeleteDistributor < Pulp::Abstract
        input_format do
          param :repo_id
          param :distributor_id
          param :capsule_id
        end

        def run
          output[:response] = pulp_resources.repository.
            delete_distributor(*input.values_at(:repo_id, :distributor_id))
        end
      end
    end
  end
end
