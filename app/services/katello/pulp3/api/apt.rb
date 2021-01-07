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

        def self.copy_class
          PulpDebClient::Copy
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

        def self.publication_verbatim_class
          PulpDebClient::DebVerbatimPublication
        end

        def self.add_remove_content_class
          PulpDebClient::RepositoryAddRemoveContent
        end

        def api_client
          api_client_class(PulpDebClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpDebClient::Configuration)))
        end

        def repositories_api
          PulpDebClient::RepositoriesAptApi.new(api_client)
        end

        def repository_versions_api
          PulpDebClient::RepositoriesAptVersionsApi.new(api_client)
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

        def copy_api
          PulpDebClient::DebCopyApi.new(api_client)
        end

        def publications_verbatim_api
          PulpDebClient::PublicationsVerbatimApi.new(api_client)
        end
      end
    end
  end
end
