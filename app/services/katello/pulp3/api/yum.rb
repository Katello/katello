require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Yum < Core
        def self.api_exception_class
          PulpRpmClient::ApiError
        end

        def self.client_module
          PulpRpmClient
        end

        def self.remote_class
          PulpRpmClient::RpmRpmRemote
        end

        def self.distribution_class
          PulpRpmClient::RpmRpmDistribution
        end

        def self.publication_class
          PulpRpmClient::RpmRpmPublication
        end

        def self.repository_sync_url_class
          PulpRpmClient::RpmRepositorySyncURL
        end

        def api_client
          PulpRpmClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpRpmClient::Configuration))
        end

        def repositories_api
          PulpRpmClient::RepositoriesRpmApi.new(api_client)
        end

        def repository_versions_api
          PulpRpmClient::RepositoriesRpmVersionsApi.new(api_client)
        end

        def remotes_api
          PulpRpmClient::RemotesRpmApi.new(api_client)
        end

        def publications_api
          PulpRpmClient::PublicationsRpmApi.new(api_client)
        end

        def distributions_api
          PulpRpmClient::DistributionsRpmApi.new(api_client)
        end
      end
    end
  end
end
