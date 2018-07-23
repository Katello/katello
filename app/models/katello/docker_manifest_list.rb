module Katello
  class DockerManifestList < Katello::Model
    include Concerns::PulpDatabaseUnit
    include Glue::Pulp::DockerManifestList

    has_many :docker_tags, :as => :docker_taggable, :class_name => "Katello::DockerTag", :dependent => :destroy
    has_many :repository_docker_manifest_lists, :class_name => "Katello::RepositoryDockerManifestList",
             :dependent => :destroy, :inverse_of => :docker_manifest_list
    has_many :repositories, :through => :repository_docker_manifest_lists, :inverse_of => :docker_manifest_lists

    has_many :docker_manifest_list_manifests, :class_name => "Katello::DockerManifestListManifest",
             :dependent => :delete_all, :inverse_of => :docker_manifest_list
    has_many :docker_manifests, :through => :docker_manifest_list_manifests, :inverse_of => :docker_manifest_lists
    has_many :docker_manifest_list_manifest_platforms, :dependent => :destroy, :class_name => "Katello::DockerManifestListManifestPlatform"
    has_many :docker_manifest_platforms, :through => :docker_manifest_list_manifest_platforms

    CONTENT_TYPE = Pulp::DockerManifestList::CONTENT_TYPE

    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true

    def self.repository_association_class
      RepositoryDockerManifestList
    end

    def self.default_sort
      order(:schema_version)
    end

    def manifest_type
      "list"
    end
  end
end
