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
          # Update ssl options by themselves workaround for https://pulp.plan.io/issues/2727
          ssl_ca_cert = input[:config].delete('ssl_ca_cert')
          ssl_client_cert = input[:config].delete('ssl_client_cert')
          ssl_client_key = input[:config].delete('ssl_client_key')

          output[:response] = pulp_resources.repository.
                                     update_importer(input[:repo_id], input[:id], :ssl_client_cert => ssl_client_cert,
                                                     :ssl_client_key => ssl_client_key, :ssl_ca_cert => ssl_ca_cert)
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
