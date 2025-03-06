require 'pulp_certguard_client'

module Katello
  module Pulp3
    module Api
      class ContentGuard < Core
        def default_name
          'RHSMCertGuard'
        end

        def client_module
          PulpCertguardClient
        end

        def self.api_exception_class
          PulpCertguardClient::ApiError
        end

        def api_client
          api_client_class(PulpCertguardClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpCertguardClient::Configuration)))
        end

        def rhsm_api_client
          PulpCertguardClient::ContentguardsRhsmApi.new(api_client)
        end

        def ca_cert
          Cert::Certs.candlepin_client_ca_cert
        end

        def refresh
          found = list(name: default_name).results.first
          if found && found.ca_certificate != ca_cert
            partial_update(found.pulp_href)
          else
            found = create
          end
          persist_if_needed(found.pulp_href)
        end

        def persist_if_needed(href)
          return if self.smart_proxy.pulp_mirror?
          Katello::Util::Support.active_record_retry do
            found = Katello::Pulp3::ContentGuard.find_by(:name => default_name)
            if found
              found.update(pulp_href: href)
            else
              Katello::Pulp3::ContentGuard.create(name: default_name, pulp_href: href)
            end
          end
        end

        def create(name = default_name)
          data = PulpCertguardClient::CertguardRHSMCertGuard.new(name: name, ca_certificate: ca_cert)
          rhsm_api_client.create(data)
        rescue self.class.api_exception_class => e
          if (found = list&.results&.first) #check for possible race condition
            found
          else
            raise e
          end
        end

        def list(options = {})
          rhsm_api_client.list options
        end

        def partial_update(href)
          data = { ca_certificate: ca_cert }
          rhsm_api_client.partial_update(href, data)
        end

        def delete(href)
          rhsm_api_client.delete(href) if href
        end
      end
    end
  end
end
