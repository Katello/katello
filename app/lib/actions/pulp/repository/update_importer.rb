module Actions
  module Pulp
    module Repository
      class UpdateImporter < Pulp::AbstractAsyncTask
        input_format do
          param :repo_id
          param :id
          param :config
          param :capsule_id
        end

        def invoke_external_task
          # Update ssl options by themselves workaround for https://pulp.plan.io/issues/2727
          ssl_ca_cert = input[:config].delete('ssl_ca_cert')
          ssl_client_cert = input[:config].delete('ssl_client_cert')
          ssl_client_key = input[:config].delete('ssl_client_key')

          # map both "" and nil to nil. Pulp does not treat "" as None.
          input[:config]['basic_auth_username'] = nil if input[:config]['basic_auth_username'].blank?
          input[:config]['basic_auth_password'] = nil if input[:config]['basic_auth_password'].blank?

          pulp_resources.repository.update_importer(input[:repo_id], input[:id], :ssl_client_cert => ssl_client_cert,
                                                    :ssl_client_key => ssl_client_key, :ssl_ca_cert => ssl_ca_cert)
          pulp_resources.repository.update_importer(*input.values_at(:repo_id, :id, :config))
        end

        def run_progress_weight
          0.01
        end
      end
    end
  end
end
