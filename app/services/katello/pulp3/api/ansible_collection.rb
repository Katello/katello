require "pulpcore_client"
# rubocop:disable ClassLength

module Katello
  module Pulp3
    module Api
      class AnsibleCollection < Core
        def self.api_exception_class
          PulpAnsibleClient::ApiError
        end

        def self.client_module
          PulpAnsibleClient
        end

        def self.remote_class
          PulpAnsibleClient::AnsibleCollectionRemote
        end

        def self.distribution_class
          PulpAnsibleClient::AnsibleAnsibleDistribution
        end

        def api_client
          PulpAnsibleClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpAnsibleClient::Configuration))
        end

        def repositories_api
          PulpAnsibleClient::RepositoriesAnsibleApi.new(api_client)
        end

        def repository_versions_api
          PulpAnsibleClient::RepositoriesAnsibleVersionsApi.new(api_client)
        end

        def remotes_api
          PulpAnsibleClient::RemotesCollectionApi.new(api_client)
        end

        def distributions_api
          PulpAnsibleClient::DistributionsAnsibleApi.new(api_client)
        end
      end
    end
  end
end
