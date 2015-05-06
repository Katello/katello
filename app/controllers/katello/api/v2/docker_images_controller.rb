module Katello
  class Api::V2::DockerImagesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a docker image"), :resource => "docker_images")
    include Katello::Concerns::Api::V2::RepositoryContentController
    include Katello::Concerns::Api::V2::RepositoryDbContentController

    private

    def resource_class
      DockerImage
    end

    def filter_by_content_view_filter(filter)
      resource_class.where(:uuid => filter.send("#{singular_resource_name}_rules").pluck(:uuid))
    end

    def custom_index_relation(collection)
      collection.includes(:docker_tags)
    end
  end
end
