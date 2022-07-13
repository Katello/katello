require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Generic < Core
        def initialize(smart_proxy, repository_type)
          super
        end

        def self.api_exception_class
          fail NotImplementedError
        end

        def self.repository_sync_url_class(repository_type)
          repository_type.repo_sync_url_class
        end
      end
    end
  end
end
