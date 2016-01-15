module Actions
  module Pulp
    module Repository
      class AssociateDistributor < Pulp::Abstract
        input_format do
          param :repo_id
          param :type_id
          param :config
          param :hash
          param :capsule_id
        end

        def run
          output[:response] = pulp_resources.repository.
            associate_distributor(*input.values_at(:repo_id, :type_id, :config, :hash))
        end
      end
    end
  end
end
