require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Apt < Core
        def publication_verbatim_class
          PulpDebClient::DebVerbatimPublication
        end

        def publications_verbatim_api
          PulpDebClient::PublicationsVerbatimApi.new(api_client)
        end

        def self.copy_class
          PulpDebClient::Copy
        end

        def self.add_remove_content_class
          PulpDebClient::RepositoryAddRemoveContent
        end

        def copy_api
          PulpDebClient::DebCopyApi.new(api_client)
        end
      end
    end
  end
end
