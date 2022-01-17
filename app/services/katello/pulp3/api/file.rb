require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class File < Core
        def self.add_remove_content_class
          PulpFileClient::RepositoryAddRemoveContent
        end

        def self.alternate_content_source_class
          PulpFileClient::FileFileAlternateContentSource
        end

        def alternate_content_source_api
          PulpFileClient::AcsFileApi.new(api_client)
        end
      end
    end
  end
end
