require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Docker < Core
        def self.recursive_manage_class
          PulpContainerClient::RecursiveManage
        end

        def self.tag_image_class
          PulpContainerClient::TagImage
        end

        def recursive_add_api
          PulpContainerClient::ContainerRecursiveAddApi.new(api_client)
        end

        def container_push_api
          PulpContainerClient::RepositoriesContainerPushApi.new(api_client)
        end

        def container_push_repo_for_name(name)
          # There should be only one repository in Pulp with the requested name
          container_push_api.list(name: name)&.results&.first
        end

        def container_push_distribution_for_repository(repository_href)
          # There should be only one repository in Pulp with the requested repository_href
          distributions_api.list(repository: repository_href)&.results&.first
        end
      end
    end
  end
end
