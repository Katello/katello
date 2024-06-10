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
      end
    end
  end
end
