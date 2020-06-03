require 'pulp_certguard_client'

module Katello
  module Pulp3
    module Api
      class ContentGuard < Core
        def self.client_module
          PulpCertguardClient
        end

        def self.api_exception_class
          PulpCertguardClient::ApiError
        end

        def api_client
          PulpCertguardClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpCertguardClient::Configuration))
        end

        def rhsm_api_client
          PulpCertguardClient::ContentguardsRhsmApi.new(api_client)
        end

        def create(name = "RHSMCertGuard", ca_certificate = Cert::Certs.ca_cert)
          data = PulpCertguardClient::CertguardRHSMCertGuard.new(name: name, ca_certificate: ca_certificate)
          rhsm_api_client.create(data)
        rescue self.class.api_exception_class => e
          raise e unless list&.results&.first
        end

        def list(options = {})
          rhsm_api_client.list options
        end

        def partial_update(href, ca_certificate = Cert::Certs.ca_cert)
          data = PulpCertguardClient::CertguardRHSMCertGuard.new(ca_certificate: ca_certificate)
          rhsm_api_client.partial_update(href, data)
        end

        def delete(href)
          rhsm_api_client.delete(href) if href
        end
      end
    end
  end
end
