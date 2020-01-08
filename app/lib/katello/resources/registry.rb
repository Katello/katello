require 'katello/util/data'

module Katello
  module Resources
    require 'rest_client'

    module Registry
      class Proxy
        def self.logger
          ::Foreman::Logging.logger('katello/registry_proxy')
        end

        def self.get(path, headers = {:accept => :json})
          logger.debug "Sending GET request to Registry: #{path}"
          resource = RegistryResource.load_class
          joined_path = resource.prefix.chomp("/") + path
          client = resource.rest_client(Net::HTTP::Get, :get, joined_path)
          client.get(headers)
        end
      end

      class RegistryResource < HttpResource
        class << self
          def load_class
            container_config = SETTINGS.dig(:katello, :container_image_registry)
            registry_url = nil
            pulp_master = ::SmartProxy.pulp_master

            # Pulp 3 has its own registry
            if pulp_master && pulp_master.pulp3_repository_type_support?(::Katello::Repository::DOCKER_TYPE)
              uri = URI(pulp_master.setting(SmartProxy::PULP3_FEATURE, 'content_app_url'))
              uri.path = "/pulpcore_registry/"
              registry_url = uri.to_s

              # Assume the registry uses the same CA as the Smart Proxy
              ca_cert_file = Setting[:ssl_ca_file]
            elsif container_config
              registry_url = container_config[:crane_url]
              ca_cert_file = container_config[:registry_ca_cert_file]
            end

            fail Errors::ContainerRegistryNotConfigured unless registry_url

            uri = URI.parse(registry_url)
            self.prefix = uri.path
            self.site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
            self.ssl_client_cert = ::Cert::Certs.ssl_client_cert
            self.ssl_client_key = ::Cert::Certs.ssl_client_key
            self.ca_cert_file = ca_cert_file
            self
          end

          def process_response(response)
            debug_level = response.code >= 400 ? :error : :debug
            logger.send(debug_level, "Registry request returned with code #{response.code}")
            super
          end
        end
      end
    end
  end
end
