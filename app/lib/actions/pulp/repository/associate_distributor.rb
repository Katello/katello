module Actions
  module Pulp
    module Repository
      class AssociateDistributor < Pulp::Abstract
        input_format do
          param :repo_id
          param :type_id
          param :config
          param :hash
        end

        def run
          output[:response] = ::Katello.pulp_server.extensions.repository.
            associate_distributor(*input.values_at(:repo_id, :type_id, :config, :hash))
        end
      end
    end
  end
end
