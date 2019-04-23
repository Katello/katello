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

        def file_publishers_api
          @file_publishers_api ||= PulpFileClient::PublishersApi.new
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

        def publishers_file_file_list(opts)
          file_publishers_api.publishers_file_file_list(opts)
        end
      end
    end
  end
end
