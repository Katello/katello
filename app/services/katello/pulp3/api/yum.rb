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

        def self.rpm_package_group_class
          PulpRpmClient::RpmPackageGroup
        end

        def self.copy_class
          PulpRpmClient::Copy
        end

        def self.add_remove_content_class
          PulpRpmClient::RepositoryAddRemoveContent
        end

        def api_client
          api_client_class(PulpRpmClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpRpmClient::Configuration)))
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

        def copy_api
          PulpRpmClient::RpmCopyApi.new(api_client)
        end

        def content_package_groups_api
          PulpRpmClient::ContentPackagegroupsApi.new(api_client)
        end

        def content_package_environments_api
          PulpRpmClient::ContentPackageenvironmentsApi.new(api_client)
        end

        def content_repo_metadata_files_api
          PulpRpmClient::ContentRepoMetadataFilesApi.new(api_client)
        end

        def content_distribution_trees_api
          PulpRpmClient::ContentDistributionTreesApi.new(api_client)
        end
      end
    end
  end
end
