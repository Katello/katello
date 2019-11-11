require "pulpcore_client"
# rubocop:disable ClassLength

module Katello
  module Pulp3
    module Api
      class Docker < Core
        def self.api_exception_class
          PulpDockerClient::ApiError
        end

        def self.client_module
          PulpDockerClient
        end

        def self.remote_class
          PulpDockerClient::DockerDockerRemote
        end

        def self.distribution_class
          PulpDockerClient::DockerDockerDistribution
        end

        def self.publication_class
          PulpDockerClient::DockerPublication
        end

        def self.recursive_manage_class
          PulpDockerClient::RecursiveManage
        end

        def api_client
          PulpDockerClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpDockerClient::Configuration))
        end

        def remotes_api
          PulpDockerClient::RemotesDockerApi.new(api_client)
        end

        def publications_api
          PulpDockerClient::PublicationsDockerApi.new(api_client)
        end

        def distributions_api
          PulpDockerClient::DistributionsDockerApi.new(api_client)
        end

        def recursive_add_api
          PulpDockerClient::DockerRecursiveAddApi.new(api_client)
        end
      end
    end
  end
end
