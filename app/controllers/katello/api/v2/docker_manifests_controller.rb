module Katello
  class Api::V2::DockerManifestsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a docker manifest"), :resource => "docker_manifests")
    include Katello::Concerns::Api::V2::RepositoryContentController

    private

    def resource_class
      DockerManifest
    end

    def filter_by_content_view_filter(filter)
      resource_class.where(:uuid => filter.send("#{singular_resource_name}_rules").pluck(:uuid))
    end

    def custom_index_relation(collection)
      collection.includes(:docker_tags)
    end
  end
end
