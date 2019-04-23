require 'pulpcore_client'
require 'pulp_file_client'

module Katello
  module Pulp
    module V3
      class Api
        def configure
          @config ||= PulpcoreClient.configure
        end

        def repositories_api
          @repositories_api ||= PulpcoreClient::RepositoriesApi.new
        end

        def distributions_api
          @distributions_api ||= PulpcoreClient::DistributionsApi.new
        end

        def file_publishers_api
          @file_publishers_api ||= PulpFileClient::PublishersApi.new
        end

        def file_remotes_api
          @file_remotes_api ||= PulpFileClient::RemotesApi.new
        end

        def repositories_create(data)
          repositories_api.repositories_create(data)
        end

        def repositories_list(args)
          repositories_api.repositories_list(args)
        end

        def repositories_delete(href)
          repositories_api.repositories_delete(href)
        end

        def repositories_versions_create(href, data)
          repositories_api.repositories_versions_create(repository_href, data)
        end

        def publishers_file_file_create(data)
          file_publishers_api.publishers_file_file_create(data)
        end

        def publishers_file_file_list(opts)
          file_publishers_api.publishers_file_file_list(opts)
        end

        def publishers_file_file_delete(href)
          file_publishers_api.publishers_file_file_delete(href)
        end

        def remotes_file_file_list(opts)
          file_remotes_api.remotes_file_file_list(opts)
        end

        def remotes_file_file_create(data)
          file_remotes_api.remotes_file_file_create(data)
        end

        def remotes_file_file_delete(href)
          file_remotes_api.remotes_file_file_delete(href)
        end

        def distributions_list(opts)
          distributions_api.distributions_list(opts)
        end

        def distributions_delete(href)
          distributions_api.distributions_delete(href)
        end
      end
    end
  end
end
