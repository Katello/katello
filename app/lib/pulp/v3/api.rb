require 'pulpcore_client'
require 'pulp_file_client'

module Pulp
  module V3
    class Api
      def configure(opts)
        [PulpcoreClient.configure, PulpFileClient.configure].each do |config|
          opts.each { |option, value| config.send("#{option}=", value) }
        end
      end

      delegate :repositories_create, to: :repositories_api
      delegate :repositories_update, to: :repositories_api
      delegate :repositories_list, to: :repositories_api
      delegate :repositories_delete, to: :repositories_api
      delegate :repositories_versions_create, to: :repositories_api

      delegate :publishers_file_file_create, to: :file_publishers_api
      delegate :publishers_file_file_list, to: :file_publishers_api
      delegate :publishers_file_file_update, to: :file_publishers_api
      delegate :publishers_file_file_delete, to: :file_publishers_api

      delegate :publications_file_file_create, to: :file_publications_api

      delegate :remotes_file_file_list, to: :file_remotes_api
      delegate :remotes_file_file_create, to: :file_remotes_api
      delegate :remotes_file_file_delete, to: :file_remotes_api
      delegate :remotes_file_file_partial_update, to: :file_remotes_api
      delegate :remotes_file_file_sync, to: :file_remotes_api

      delegate :distributions_file_file_create, to: :file_distributions_api
      delegate :distributions_file_file_list, to: :file_distributions_api
      delegate :distributions_file_file_read, to: :file_distributions_api
      delegate :distributions_file_file_delete, to: :file_distributions_api
      delegate :distributions_file_file_partial_update, to: :file_distributions_api

      delegate :tasks_read, to: :tasks_api

      def repositories_api
        @repositories_api ||= PulpcoreClient::RepositoriesApi.new
      end

      def file_distributions_api
        @file_distributions_api ||= PulpFileClient::DistributionsApi.new
      end

      def file_publishers_api
        @file_publishers_api ||= PulpFileClient::PublishersApi.new
      end

      def file_publications_api
        @file_publications_api ||= PulpFileClient::PublicationsApi.new
      end

      def file_remotes_api
        @file_remotes_api ||= PulpFileClient::RemotesApi.new
      end

      def tasks_api
        @tasks_api ||= PulpcoreClient::TasksApi.new
      end
    end
  end
end
