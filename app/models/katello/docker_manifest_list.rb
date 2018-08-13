module Katello
  class DockerManifestList < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :docker_tags, :as => :docker_taggable, :class_name => "Katello::DockerTag", :dependent => :destroy
    has_many :repository_docker_manifest_lists, :class_name => "Katello::RepositoryDockerManifestList",
             :dependent => :destroy, :inverse_of => :docker_manifest_list
    has_many :repositories, :through => :repository_docker_manifest_lists, :inverse_of => :docker_manifest_lists

    has_many :docker_manifest_list_manifests, :class_name => "Katello::DockerManifestListManifest",
             :dependent => :delete_all, :inverse_of => :docker_manifest_list
    has_many :docker_manifests, :through => :docker_manifest_list_manifests, :inverse_of => :docker_manifest_lists

    CONTENT_TYPE = Pulp::DockerManifestList::CONTENT_TYPE

    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true

    def self.repository_association_class
      RepositoryDockerManifestList
    end

    def update_from_json(json)
      update_attributes(:schema_version => json[:schema_version],
                        :digest => json[:digest],
                        :downloaded => json[:downloaded],
                        :docker_manifests => ::Katello::DockerManifest.where(:digest => json[:manifests].pluck(:digest))
                       )
    end

    def self.default_sort
      order(:schema_version)
    end

    def manifest_type
      "list"
    end
  end
end
