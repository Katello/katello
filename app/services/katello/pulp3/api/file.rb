require "pulpcore_client"
# rubocop:disable ClassLength

module Katello
  module Pulp3
    module Api
      class File < Core
        def self.api_exception_class
          PulpFileClient::ApiError
        end

        def self.client_module
          PulpFileClient
        end

        def self.remote_class
          PulpFileClient::FileFileRemote
        end

        def self.distribution_class
          PulpFileClient::FileFileDistribution
        end

        def self.publication_class
          PulpFileClient::FileFilePublication
        end

        def api_client
          PulpFileClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpFileClient::Configuration))
        end

        def repositories_api
          PulpFileClient::RepositoriesFileApi.new(api_client)
        end

        def repository_versions_api
          PulpFileClient::RepositoriesFileVersionsApi.new(api_client)
        end

        def remotes_api
          PulpFileClient::RemotesFileApi.new(api_client)
        end

        def publications_api
          PulpFileClient::PublicationsFileApi.new(api_client)
        end

        def distributions_api
          PulpFileClient::DistributionsFileApi.new(api_client)
        end
      end
    end
  end
end
