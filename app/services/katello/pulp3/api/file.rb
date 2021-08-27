require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class File < Core
        def self.add_remove_content_class
          PulpFileClient::RepositoryAddRemoveContent
        end
      end
    end
  end
end
