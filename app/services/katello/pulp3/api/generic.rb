require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Generic < Core
        def self.api_exception_class
          fail NotImplementedError
        end

        def self.distribution_class(repository_type)
          repository_type.distribution_class
        end

        def self.publication_class(repository_type)
          repository_type.publication_class
        end

        def self.repository_sync_url_class(repository_type)
          repository_type.repo_sync_url_class
        end

        def self.add_remove_content_class
          fail NotImplementedError
        end

        def api_client
          api_client_class(@repository_type.api_class.new(smart_proxy.pulp3_configuration(@repository_type.configuration_class)))
        end

        def repositories_api
          @repository_type.repositories_api_class.new(api_client)
        end

        def repository_versions_api
          @repository_type.repository_versions_api_class.new(api_client)
        end

        def remotes_api
          @repository_type.remotes_api_class.new(api_client)
        end

        def publications_api
          @repository_type.publications_api_class.new(api_client)
        end

        def distributions_api
          @repository_type.distributions_api_class.new(api_client)
        end
      end
    end
  end
end
