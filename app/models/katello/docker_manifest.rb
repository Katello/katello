module Katello
  class DockerManifest < Katello::Model
    include Concerns::PulpDatabaseUnit
    include Glue::Pulp::DockerManifest

    has_many :docker_tags, :as => :docker_taggable, :class_name => "Katello::DockerTag", :dependent => :destroy
    has_many :repository_docker_manifests, :class_name => "Katello::RepositoryDockerManifest",
             :dependent => :destroy, :inverse_of => :docker_manifest
    has_many :repositories, :through => :repository_docker_manifests, :inverse_of => :docker_manifests

    has_many :docker_manifest_list_manifests, :class_name => "Katello::DockerManifestListManifest",
             :dependent => :delete_all, :inverse_of => :docker_manifest
    has_many :docker_manifest_lists, :through => :docker_manifest_list_manifests, :inverse_of => :docker_manifests
    has_many :docker_manifest_manifest_platforms, :dependent => :destroy, :class_name => "Katello::DockerManifestManifestPlatform"
    has_many :docker_manifest_platforms, :through => :docker_manifest_manifest_platforms

    CONTENT_TYPE = Pulp::DockerManifest::CONTENT_TYPE
    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true
    scoped_search :relation => :docker_manifest_lists, :on => :digest, :rename => :manifest_list_digest, :complete_value => true, :only_explicit => true

    def self.repository_association_class
      RepositoryDockerManifest
    end

    def self.default_sort
      order(:schema_version)
    end

    def manifest_type
      "image"
    end
  end
end
