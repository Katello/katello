module Katello
  class Api::V2::DockerManifestListsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a docker manifest list"), :resource => "docker_manifest_lists")
    include Katello::Concerns::Api::V2::RepositoryContentController

    private

    def resource_class
      DockerManifestList
    end

    def custom_index_relation(collection)
      collection.includes(:docker_tags)
    end

    def default_sort
      lambda { |query| query.default_sort }
    end
  end
end
