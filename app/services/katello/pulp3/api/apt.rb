require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Apt < Core
        def self.api_exception_class
          PulpDebClient::ApiError
        end

        def self.client_module
          PulpDebClient
        end

        def self.remote_class
          PulpDebClient::DebAptRemote
        end

        def self.distribution_class
          PulpDebClient::DebAptDistribution
        end

        def self.publication_class
          PulpDebClient::DebAptPublication
        end

        def self.repository_sync_url_class
          PulpDebClient::RepositorySyncURL
        end

        def api_client
          PulpDebClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpDebClient::Configuration))
        end

        def repositories_api
          PulpDebClient::RepositoriesAptApi.new(api_client)
        end

        def repository_versions_api
          PulpDebClient::RepositoriesDebVersionsApi.new(api_client)
        end

        def remotes_api
          PulpDebClient::RemotesAptApi.new(api_client)
        end

        def publications_api
          PulpDebClient::PublicationsAptApi.new(api_client)
        end

        def distributions_api
          PulpDebClient::DistributionsAptApi.new(api_client)
        end
      end
    end
  end
end
