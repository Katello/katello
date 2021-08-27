require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class AnsibleCollection < Core
        def self.copy_class
          PulpAnsibleClient::Copy
        end

        def self.add_remove_content_class
          PulpAnsibleClient::RepositoryAddRemoveContent
        end

        def copy_api
          PulpAnsibleClient::AnsibleCopyApi.new(api_client)
        end
      end
    end
  end
end
