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
      end
    end
  end
end
