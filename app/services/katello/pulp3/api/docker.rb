require "pulpcore_client"
# rubocop:disable ClassLength

module Katello
  module Pulp3
    module Api
      class Docker < Core
        def self.api_exception_class
          PulpContainerClient::ApiError
        end

        def self.client_module
          PulpContainerClient
        end

        def self.remote_class
          PulpContainerClient::ContainerContainerRemote
        end

        def self.distribution_class
          PulpContainerClient::ContainerContainerDistribution
        end

        def self.publication_class
          PulpContainerClient::ContainerPublication
        end

        def self.recursive_manage_class
          PulpContainerClient::RecursiveManage
        end

        def api_client
          PulpContainerClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpContainerClient::Configuration))
        end

        def repositories_api
          PulpContainerClient::RepositoriesContainerApi.new(api_client)
        end

        def repository_versions_api
          PulpContainerClient::RepositoriesContainerVersionsApi.new(api_client)
        end

        def remotes_api
          PulpContainerClient::RemotesContainerApi.new(api_client)
        end

        def publications_api
          PulpContainerClient::PublicationsContainerApi.new(api_client)
        end

        def distributions_api
          PulpContainerClient::DistributionsContainerApi.new(api_client)
        end

        def recursive_add_api
          PulpContainerClient::ContainerRecursiveAddApi.new(api_client)
        end
      end
    end
  end
end
