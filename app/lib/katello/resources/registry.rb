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
          client = RegistryResource.rest_client(Net::HTTP::Get, :get, path)
          client.get(headers)
        end
      end

      class RegistryResource < HttpResource
        if SETTINGS[:katello][:registry]
          cfg = SETTINGS[:katello][:registry]
          url = cfg[:url]
          uri = URI.parse(url)
          self.prefix = uri.path
          self.site = "#{uri.scheme}://#{uri.host}:#{uri.port}"
          self.ca_cert_file = cfg[:ca_cert_file]
        end

        class << self
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
