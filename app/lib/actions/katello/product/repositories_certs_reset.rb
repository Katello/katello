module Actions
  module Katello
    module Product
      class RepositoriesCertsReset < Actions::AbstractAsyncTask
        def plan(product)
          ssl_ca_cert_id = product.ssl_ca_cert_id
          ssl_client_cert_id = product.ssl_client_cert_id
          ssl_client_key_id = product.ssl_client_key_id
          # Plan Repository::Update only for repositories which have different certs key
          product.repositories.each do |repo|
            if (repo.ssl_ca_cert_id != ssl_ca_cert_id ||
                repo.ssl_client_cert_id != ssl_client_cert_id ||
                repo.ssl_client_key_id != ssl_client_key_id)
              plan_action(::Actions::Katello::Repository::Update,
                          repo,
                          :ssl_ca_cert_id => ssl_ca_cert_id,
                          :ssl_client_cert_id => ssl_client_cert_id,
                          :ssl_client_key_id => ssl_client_key_id)
            end
          end
        end
      end
    end
  end
end
