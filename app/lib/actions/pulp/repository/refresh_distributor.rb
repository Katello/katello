module Actions
  module Pulp
    module Repository
      class RefreshDistributor < Pulp::Abstract
        input_format do
          param :repo_id
          param :id
          param :config
        end

        def run
          output[:response] = ::Katello.pulp_server.extensions.repository.
            update_distributor(*input.values_at(:repo_id, :id, :config))
        end
      end
    end
  end
end
